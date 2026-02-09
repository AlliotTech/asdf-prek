<div align="center">

# asdf-prek

[![CI](https://github.com/AlliotTech/asdf-prek/actions/workflows/ci.yml/badge.svg)](https://github.com/AlliotTech/asdf-prek/actions/workflows/ci.yml)

[`prek`](https://github.com/j178/prek) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

## About prek

`prek` is a fast Rust-based CLI for maintaining Python lint suppressions (such as `# noqa`) and related workflows.

- Upstream project: https://github.com/j178/prek
- Documentation: https://prek.j178.dev/

## Dependencies

- `bash`
- `curl`
- `tar`
- `git` (for `asdf list all prek`)

## Install

```bash
asdf plugin add prek https://github.com/AlliotTech/asdf-prek.git
```

Show all available versions:

```bash
asdf list all prek
```

Install a version:

```bash
asdf install prek latest
# or
asdf install prek <version>
```

Set global/local version:

```bash
asdf global prek latest
# or
asdf local prek <version>
```

Verify:

```bash
prek --version
```

## Supported Platforms

This plugin installs official `prek` release binaries for:

- macOS: `x86_64`, `aarch64`
- Linux (glibc): `x86_64`, `aarch64`

## Troubleshooting

If download or install fails:

1. Confirm your platform/architecture has an upstream `prek` release asset.
2. Retry with a specific version (instead of `latest`).
3. If you hit GitHub API rate limits, set `GITHUB_API_TOKEN`.

## Contributing

Issues and PRs are welcome.

## License

See [LICENSE](LICENSE).
