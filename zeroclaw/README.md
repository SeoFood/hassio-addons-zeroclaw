# Home Assistant Add-on: ZeroClaw

This add-on packages [ZeroClaw](https://github.com/zeroclaw-labs/zeroclaw) and runs its daemon service.

## Features

- Multi-arch build target: `amd64`, `aarch64`
- Daemon-only runtime for channels (Discord, Telegram, Slack, ...)
- Configurable persistent data directory via `persistent_data_dir` (use `/share/...` for easy backup/restore)
- Channel config is read from `channels.toml` in the active persistent data directory
- Persistent data in `/data/zeroclaw` by default

See `DOCS.md` for configuration details.
