# Home Assistant Add-on: ZeroClaw

This add-on packages [ZeroClaw](https://github.com/zeroclaw-labs/zeroclaw) and runs its gateway or daemon service.

## Features

- Multi-arch build target: `amd64`, `aarch64`
- Ingress support
- Runtime mode switch: `gateway` or `daemon`
- Built-in UI form over Ingress (`3010` frontend)
- Configurable persistent data directory via `persistent_data_dir` (use `/share/...` for easy backup/restore)
- Channel config is read from `channels.toml` in the active persistent data directory
- Persistent data in `/data/zeroclaw` by default

See `DOCS.md` for configuration details.
