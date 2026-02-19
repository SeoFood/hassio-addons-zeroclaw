# Home Assistant Add-on: ZeroClaw

This add-on packages [ZeroClaw](https://github.com/zeroclaw-labs/zeroclaw) and runs its gateway or daemon service.

## Features

- Multi-arch build target: `amd64`, `aarch64`
- Ingress support
- Runtime mode switch: `gateway` or `daemon`
- Built-in UI form over Ingress (`3010` frontend)
- Directory-based channel config via `channels_config_dir` (`/share/<dir>/channels.toml`)
- Persistent data in `/data`

See `DOCS.md` for configuration details.
