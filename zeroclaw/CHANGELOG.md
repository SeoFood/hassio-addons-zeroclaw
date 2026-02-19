# Changelog

## 0.1.0-3

- Added `runtime_mode` option (`gateway` or `daemon`) to run webhook or channel-listener workflows.
- Added generic `channels_config_toml` option to append managed channel config blocks.
- Added config validation step (`zeroclaw channel list`) when `channels_config_toml` is set.
- Added stable add-on watchdog endpoint `/addon-health`.
- Updated Ingress UI and documentation with runtime mode guidance and Discord setup example.

## 0.1.0-2

- Added Ingress UI form for `health`, `pair`, and `webhook`.
- Switched frontend port to `3010` and proxied gateway backend to `3011`.
- Added `require_pairing` add-on option with default `false`.

## 0.1.0-1

- Initial Home Assistant add-on for ZeroClaw.
- Multi-arch setup for `aarch64` and `amd64`.
- Ingress-enabled gateway on port `3000`.
