#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/j178/prek"
TOOL_NAME="prek"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts+=( -H "Authorization: token $GITHUB_API_TOKEN" )
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' |
    cut -d/ -f3- |
    sed 's/^v//' |
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+([-.].*)?$'
}

list_all_versions() {
  list_github_tags
}

list_stable_versions() {
  list_all_versions | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$'
}

get_latest_stable_version() {
  local version
  version=$(list_stable_versions | sort_versions | tail -n1 | xargs echo)

  if [ -z "$version" ]; then
    version=$(list_all_versions | sort_versions | tail -n1 | xargs echo)
  fi

  if [ -z "$version" ]; then
    fail "No installable versions found"
  fi

  printf "%s\n" "$version"
}

resolve_version() {
  local version="$1"

  if [ "$version" = "latest" ]; then
    get_latest_stable_version
    return 0
  fi

  printf "%s\n" "${version#v}"
}

get_os() {
  local os
  os=$(uname -s)

  case "$os" in
    Linux) echo "unknown-linux-gnu" ;;
    Darwin) echo "apple-darwin" ;;
    *) fail "Unsupported OS: $os" ;;
  esac
}

get_arch() {
  local arch
  arch=$(uname -m)

  case "$arch" in
    x86_64 | amd64) echo "x86_64" ;;
    aarch64 | arm64) echo "aarch64" ;;
    *) fail "Unsupported architecture: $arch" ;;
  esac
}

get_release_filename() {
  local version="$1"
  local arch os
  arch=$(get_arch)
  os=$(get_os)

  printf "%s-%s-%s.tar.gz" "$TOOL_NAME" "$arch" "$os"
}

download_release() {
  local version filename normalized_version release_filename url
  version="$1"
  filename="$2"

  normalized_version=$(resolve_version "$version")
  release_filename=$(get_release_filename "$normalized_version")
  url="$GH_REPO/releases/download/v${normalized_version}/${release_filename}"

  echo "* Downloading $TOOL_NAME release $normalized_version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

resolve_downloaded_binary() {
  if [ -x "$ASDF_DOWNLOAD_PATH/$TOOL_NAME" ]; then
    printf "%s\n" "$ASDF_DOWNLOAD_PATH/$TOOL_NAME"
    return 0
  fi

  local match
  match=$(find "$ASDF_DOWNLOAD_PATH" -maxdepth 3 -type f -name "$TOOL_NAME" -perm -u+x | head -n1 || true)

  if [ -n "$match" ]; then
    printf "%s\n" "$match"
    return 0
  fi

  return 1
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path/bin"

    local source_bin
    source_bin=$(resolve_downloaded_binary) || fail "Could not find downloaded $TOOL_NAME binary"

    cp "$source_bin" "$install_path/bin/$TOOL_NAME"
    chmod +x "$install_path/bin/$TOOL_NAME"

    test -x "$install_path/bin/$TOOL_NAME" || fail "Expected $install_path/bin/$TOOL_NAME to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
