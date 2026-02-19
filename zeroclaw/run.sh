#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE="/data/options.json"
STATE_DIR="/data/zeroclaw"

read_opt() {
    local key="$1"
    local default="${2:-}"

    if [[ -f "${OPTIONS_FILE}" ]]; then
        local value
        value="$(jq -r "${key} // empty" "${OPTIONS_FILE}" 2>/dev/null || true)"
        if [[ -n "${value}" ]]; then
            echo "${value}"
            return
        fi
    fi

    echo "${default}"
}

API_KEY="$(read_opt '.api_key' '')"
PROVIDER="$(read_opt '.provider' 'openrouter')"
MODEL="$(read_opt '.model' '')"
ALLOW_PUBLIC_BIND="$(read_opt '.allow_public_bind' 'true')"
GATEWAY_HOST="$(read_opt '.gateway_host' '0.0.0.0')"

if [[ -z "${API_KEY}" ]]; then
    echo "ERROR: Option 'api_key' fehlt oder ist leer." >&2
    exit 1
fi

mkdir -p "${STATE_DIR}/.zeroclaw" "${STATE_DIR}/workspace"

export HOME="${STATE_DIR}"
export ZEROCLAW_WORKSPACE="${STATE_DIR}/workspace"
export API_KEY
export PROVIDER
export ZEROCLAW_ALLOW_PUBLIC_BIND="${ALLOW_PUBLIC_BIND}"
export ZEROCLAW_GATEWAY_HOST="${GATEWAY_HOST}"
export ZEROCLAW_GATEWAY_PORT="3000"

if [[ -n "${MODEL}" && "${MODEL}" != "null" ]]; then
    export ZEROCLAW_MODEL="${MODEL}"
fi

echo "=========================================="
echo "ZeroClaw Gateway"
echo "Provider: ${PROVIDER}"
echo "Bind: ${GATEWAY_HOST}:3000"
echo "=========================================="

exec /usr/local/bin/zeroclaw gateway
