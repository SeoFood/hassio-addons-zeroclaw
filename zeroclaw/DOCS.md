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
- `channels_config_file`: TOML file path for channels config (relative paths resolve under `/share`); leave empty to disable.
- `channels_config_toml`: raw TOML block appended to `~/.zeroclaw/config.toml`; leave empty to disable.

## Runtime modes

- `gateway`: ZeroClaw gateway is started. Use this for `/pair` and `/webhook`.
- `daemon`: ZeroClaw daemon is started. Use this for channel listeners (Discord, Telegram, Slack, ...).

## Discord setup example

Recommended: Set `runtime_mode` to `daemon` and use `channels_config_file`.

```yaml
runtime_mode: daemon
channels_config_file: zeroclaw/channels.toml
```

Create `/share/zeroclaw/channels.toml` with:

```toml
[channels_config.discord]
bot_token = "discord-bot-token"
guild_id = "123456789012345678"
allowed_users = ["123456789012345678"]
listen_to_bots = false
mention_only = false
```

Fallback:
- If `channels_config_file` is empty, `channels_config_toml` is used.
- If both are set, `channels_config_file` takes priority.

Security note:
- Avoid `allowed_users = ["*"]` in production. Use explicit Discord user IDs.

## Notes

- Data is persisted in `/data`.
- `/share` is mounted read/write for file-based channel config.
- Ingress serves a small UI on port `3010`.
- ZeroClaw runtime (`gateway` or `daemon`) runs behind Nginx.
- Add-on health endpoint for watchdog: `/addon-health` (always `200` while Nginx is up).
- Gateway endpoints (`/health`, `/pair`, `/webhook`) are only meaningful in `gateway` mode.
- The host port mapping is disabled by default because Ingress is enabled.
