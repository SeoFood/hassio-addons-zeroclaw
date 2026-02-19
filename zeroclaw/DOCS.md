# ZeroClaw

Run the ZeroClaw gateway as a Home Assistant add-on and access it via Ingress.

## Configuration

- `provider` (required): LLM provider name (`openrouter`, `openai`, `anthropic`, `ollama`, ...)
- `api_key` (required): API key for your provider
- `model` (optional): explicit model override
- `require_pairing`: requires `/pair` before webhook requests (default `false` for easier HA usage)
- `allow_public_bind`: keep enabled when `gateway_host` is `0.0.0.0`
- `gateway_host`: bind address (default `0.0.0.0`)

## Notes

- Data is persisted in `/data`.
- Ingress serves a small UI on port `3010`.
- ZeroClaw gateway runs internally on port `3011` behind Nginx.
- The host port mapping is disabled by default because Ingress is enabled.
