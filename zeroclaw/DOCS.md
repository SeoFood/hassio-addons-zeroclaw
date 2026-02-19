# ZeroClaw

Run ZeroClaw as a Home Assistant add-on and access it via Ingress.

## Configuration

- `runtime_mode`: `gateway` or `daemon` (default: `gateway`)
- `provider` (required): LLM provider name (`openrouter`, `openai`, `anthropic`, `ollama`, ...)
- `api_key` (required): API key for your provider
- `model` (optional): explicit model override
- `require_pairing`: requires `/pair` before webhook requests (default `false` for easier HA usage)
- `allow_public_bind`: keep enabled when `gateway_host` is `0.0.0.0`
- `gateway_host`: bind address (default `0.0.0.0`)
- `persistent_data_dir`: optional folder for all persistent add-on data (memory, cron, workspace, config, `channels.toml`). Relative paths resolve under `/share`.

## Runtime modes

- `gateway`: ZeroClaw gateway is started. Use this for `/pair` and `/webhook`.
- `daemon`: ZeroClaw daemon is started. Use this for channel listeners (Discord, Telegram, Slack, ...).

## Discord setup example

Recommended: Set `runtime_mode` to `daemon` and use `persistent_data_dir`.

```yaml
runtime_mode: daemon
persistent_data_dir: zeroclaw
```

Then edit `/share/zeroclaw/channels.toml` (created automatically on first start) with:

```toml
[channels_config.discord]
bot_token = "discord-bot-token"
guild_id = "123456789012345678"
allowed_users = ["123456789012345678"]
listen_to_bots = false
mention_only = false
```

Security note:
- Avoid `allowed_users = ["*"]` in production. Use explicit Discord user IDs.

## Notes

- Default persistent data path is `/data/zeroclaw`.
- If `persistent_data_dir` is set, persistent data is stored there instead (for example `/share/zeroclaw`).
- On first start with `persistent_data_dir`, existing data from `/data/zeroclaw` is auto-migrated when the target folder is empty.
- `channels.toml` is always read from the active persistent data directory.
- Ingress serves a small UI on port `3010`.
- ZeroClaw runtime (`gateway` or `daemon`) runs behind Nginx.
- Add-on health endpoint for watchdog: `/addon-health` (always `200` while Nginx is up).
- Gateway endpoints (`/health`, `/pair`, `/webhook`) are only meaningful in `gateway` mode.
- The host port mapping is disabled by default because Ingress is enabled.
