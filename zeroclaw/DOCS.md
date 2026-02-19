# ZeroClaw

Run the ZeroClaw gateway as a Home Assistant add-on and access it via Ingress.

## Configuration

- `provider` (required): LLM provider name (`openrouter`, `openai`, `anthropic`, `ollama`, ...)
- `api_key` (required): API key for your provider
- `model` (optional): explicit model override
- `allow_public_bind`: keep enabled when `gateway_host` is `0.0.0.0`
- `gateway_host`: bind address (default `0.0.0.0`)

## Notes

- Data is persisted in `/data`.
- The add-on starts `zeroclaw gateway` on port `3000`.
- The host port mapping is disabled by default because Ingress is enabled.
