# ZeroClaw

Run ZeroClaw daemon as a Home Assistant add-on.

## Configuration

- `provider` (required): LLM provider name (`openrouter`, `openai`, `anthropic`, `ollama`, ...)
- `api_key` (required): API key for your provider
- `model` (optional): explicit model override
- `autonomy_mode`: `default` or `full_access`
- `persistent_data_dir`: optional folder for all persistent add-on data (memory, cron, workspace, config, `channels.toml`). Relative paths resolve under `/share`.

## Discord setup example

Use `persistent_data_dir` and run the add-on.

```yaml
autonomy_mode: full_access
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
- The add-on runs ZeroClaw in daemon mode.

## Autonomy modes

- `default`:
  - `level = "supervised"`
  - `workspace_only = true`
  - `require_approval_for_medium_risk = true`
  - `block_high_risk_commands = true`
- `full_access`:
  - `level = "full"`
  - `workspace_only = false`
  - `require_approval_for_medium_risk = false`
  - `block_high_risk_commands = false`

Security warning:
- `full_access` allows unrestricted command execution and filesystem access beyond the workspace.
