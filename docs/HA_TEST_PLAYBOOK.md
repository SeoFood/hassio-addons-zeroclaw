# ZeroClaw Add-on Test Playbook (Home Assistant)

## Goal

Verify that the `zeroclaw` add-on installs and runs correctly on `amd64` and `aarch64`, using daemon mode only.

## Prerequisites

- Home Assistant OS with Supervisor
- Access to the Add-on Store
- This repository added as an add-on source
- A valid LLM API key (for example OpenRouter, OpenAI, or Anthropic)

## 1. Add repository

1. Open Add-on Store.
2. Open the top-right menu and select Repositories.
3. Add `https://github.com/SeoFood/hassio-addons-zeroclaw`.
4. Save and reload the store.

## 2. Install add-on

1. Open add-on `ZeroClaw`.
2. Install it.
3. Do not start yet; set config first.

## 3. Base configuration

Use this configuration:

```yaml
provider: openrouter
api_key: "<YOUR_API_KEY>"
model: ""
persistent_data_dir: zeroclaw
```

Note: `api_key` is required. The add-on exits by design when it is missing.

## 4. Start and log checks

1. Start the add-on.
2. Check logs. Expected:
   - `ZeroClaw Add-on`
   - `Runtime mode: daemon`
   - `State dir: /share/zeroclaw` (if `persistent_data_dir: zeroclaw`)
   - no immediate crash/exit
3. Confirm `channels.toml` exists:
   - `/share/zeroclaw/channels.toml`

## 5. Discord functional test

1. Edit `/share/zeroclaw/channels.toml` with your Discord channel config.
2. Restart the add-on.
3. Send a test message to the bot.
4. Expected:
   - bot responds
   - no provider/auth errors in logs

## 6. Persistence test

1. Create a cron job from the running ZeroClaw runtime.
2. Stop the add-on.
3. Restart Home Assistant.
4. Start the add-on again.
5. Expected:
   - startup still succeeds
   - state in `/share/zeroclaw` is preserved (memory DB, cron state, config, workspace)

## 7. Negative tests

- `api_key` empty: add-on must fail with a clear error.
- Invalid `provider`: add-on starts, but provider errors appear during requests.
- Invalid TOML in `/share/zeroclaw/channels.toml`: add-on fails with channel config validation error.

## 8. Architecture matrix

Run at least once on:

- `amd64` (for example x86 mini PC or VM)
- `aarch64` (for example Raspberry Pi 4/5 64-bit)

## 9. Acceptance criteria

- Installation successful
- Start successful
- Discord channel flow works
- Persistence works across restart/reboot
- No regressions on `amd64` and `aarch64`
