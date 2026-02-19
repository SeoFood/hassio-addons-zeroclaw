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
REQUIRE_PAIRING="$(read_opt '.require_pairing' 'false')"
ALLOW_PUBLIC_BIND="$(read_opt '.allow_public_bind' 'true')"
GATEWAY_HOST="$(read_opt '.gateway_host' '0.0.0.0')"

if [[ -z "${API_KEY}" ]]; then
    echo "ERROR: Option 'api_key' fehlt oder ist leer." >&2
    exit 1
fi

mkdir -p "${STATE_DIR}/.zeroclaw" "${STATE_DIR}/workspace"

case "${REQUIRE_PAIRING,,}" in
    1|true|yes|on) REQUIRE_PAIRING="true" ;;
    0|false|no|off|"") REQUIRE_PAIRING="false" ;;
    *)
        echo "WARN: Ungueltiger Wert fuer require_pairing (${REQUIRE_PAIRING}), nutze false." >&2
        REQUIRE_PAIRING="false"
        ;;
esac

export HOME="${STATE_DIR}"
export ZEROCLAW_WORKSPACE="${STATE_DIR}/workspace"

CONFIG_FILE="${STATE_DIR}/.zeroclaw/config.toml"
if [[ ! -f "${CONFIG_FILE}" ]]; then
    /usr/local/bin/zeroclaw status >/dev/null 2>&1 || true
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "ERROR: Konnte ${CONFIG_FILE} nicht erzeugen." >&2
    exit 1
fi

if grep -Eq '^[[:space:]]*require_pairing[[:space:]]*=' "${CONFIG_FILE}"; then
    sed -E -i "s/^[[:space:]]*require_pairing[[:space:]]*=.*/require_pairing = ${REQUIRE_PAIRING}/" "${CONFIG_FILE}"
elif grep -Eq '^[[:space:]]*\[gateway\][[:space:]]*$' "${CONFIG_FILE}"; then
    awk -v req="${REQUIRE_PAIRING}" '
        { print }
        /^[[:space:]]*\[gateway\][[:space:]]*$/ && !inserted {
            print "require_pairing = " req
            inserted = 1
        }
    ' "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp"
    mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"
else
    {
        printf "\n[gateway]\n"
        printf "require_pairing = %s\n" "${REQUIRE_PAIRING}"
    } >> "${CONFIG_FILE}"
fi

chmod 600 "${CONFIG_FILE}" || true
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
echo "Require pairing: ${REQUIRE_PAIRING}"
echo "=========================================="

exec /usr/local/bin/zeroclaw gateway
