# Changelog

## 0.1.0-7

- Added `persistent_data_dir` to store all persistent runtime data (memory, cron, workspace, config) in a custom folder.
- Added first-start migration from `/data/zeroclaw` to `persistent_data_dir` when the target folder is empty.
- `channels_config_dir` now defaults to `persistent_data_dir` when set, so one folder can be used for everything.

## 0.1.0-6

- Switched to a single `channels_config_dir` option and removed legacy `channels_config_file` / `channels_config_toml` options.
- Add-on now auto-creates `<channels_config_dir>/channels.toml` with a starter template on first start.
- Updated docs and option labels for the directory-only workflow.

## 0.1.0-5

- Fixed option-save issues by switching `channels_config_file` and `channels_config_toml` defaults from `null` to empty strings.
- Updated add-on schema so both fields are plain `str`, avoiding `None`/missing-option validation errors.

## 0.1.0-4

- Added `channels_config_file` option for file-based TOML config with editor-friendly workflow.
- Added `/share` mount to support external channel config files.
- Updated startup logic: if both `channels_config_file` and `channels_config_toml` are set, file-based config wins.
- Updated docs with file-based Discord example.

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
