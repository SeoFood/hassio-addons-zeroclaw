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
- `channels_config_toml` (optional): raw TOML block appended to `~/.zeroclaw/config.toml`

## Runtime modes

- `gateway`: ZeroClaw gateway is started. Use this for `/pair` and `/webhook`.
- `daemon`: ZeroClaw daemon is started. Use this for channel listeners (Discord, Telegram, Slack, ...).

## Discord setup example

Set `runtime_mode` to `daemon` and provide `channels_config_toml` like this:

```yaml
runtime_mode: daemon
channels_config_toml: |
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

- Data is persisted in `/data`.
- Ingress serves a small UI on port `3010`.
- ZeroClaw runtime (`gateway` or `daemon`) runs behind Nginx.
- Add-on health endpoint for watchdog: `/addon-health` (always `200` while Nginx is up).
- Gateway endpoints (`/health`, `/pair`, `/webhook`) are only meaningful in `gateway` mode.
- The host port mapping is disabled by default because Ingress is enabled.
