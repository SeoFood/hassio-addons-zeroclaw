#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE="/data/options.json"
STATE_DIR="/data/zeroclaw"
FRONTEND_PORT="3010"
BACKEND_PORT="3011"
MANAGED_BEGIN="# --- zeroclaw-addon:channels-config begin ---"
MANAGED_END="# --- zeroclaw-addon:channels-config end ---"

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

strip_managed_block() {
    local file="$1"
    awk -v begin="${MANAGED_BEGIN}" -v end="${MANAGED_END}" '
        $0 == begin { skip = 1; next }
        $0 == end { skip = 0; next }
        !skip { print }
    ' "${file}" > "${file}.tmp"
    mv "${file}.tmp" "${file}"
}

append_managed_block() {
    local file="$1"
    local block="$2"
    {
        printf "\n%s\n" "${MANAGED_BEGIN}"
        printf "%s\n" "${block}"
        printf "%s\n" "${MANAGED_END}"
    } >> "${file}"
}

RUNTIME_MODE="$(read_opt '.runtime_mode' 'gateway')"
API_KEY="$(read_opt '.api_key' '')"
PROVIDER="$(read_opt '.provider' 'openrouter')"
MODEL="$(read_opt '.model' '')"
REQUIRE_PAIRING="$(read_opt '.require_pairing' 'false')"
ALLOW_PUBLIC_BIND="$(read_opt '.allow_public_bind' 'true')"
GATEWAY_HOST="$(read_opt '.gateway_host' '0.0.0.0')"
CHANNELS_CONFIG_FILE="$(read_opt '.channels_config_file' '')"
CHANNELS_CONFIG_TOML="$(read_opt '.channels_config_toml' '')"

RUNTIME_MODE="${RUNTIME_MODE,,}"
case "${RUNTIME_MODE}" in
    gateway|daemon) ;;
    *)
        echo "WARN: Ungueltiger Wert fuer runtime_mode (${RUNTIME_MODE}), nutze gateway." >&2
        RUNTIME_MODE="gateway"
        ;;
esac

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

strip_managed_block "${CONFIG_FILE}"

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

if [[ "${CHANNELS_CONFIG_FILE}" == "null" ]]; then
    CHANNELS_CONFIG_FILE=""
fi
if [[ "${CHANNELS_CONFIG_TOML}" == "null" ]]; then
    CHANNELS_CONFIG_TOML=""
fi

CHANNELS_CONFIG_BLOCK=""
CHANNELS_CONFIG_SOURCE=""
if [[ -n "${CHANNELS_CONFIG_FILE}" ]]; then
    if [[ "${CHANNELS_CONFIG_FILE}" != /* ]]; then
        CHANNELS_CONFIG_FILE="/share/${CHANNELS_CONFIG_FILE}"
    fi
    if [[ ! -f "${CHANNELS_CONFIG_FILE}" ]]; then
        echo "ERROR: channels_config_file nicht gefunden: ${CHANNELS_CONFIG_FILE}" >&2
        exit 1
    fi
    CHANNELS_CONFIG_BLOCK="$(cat "${CHANNELS_CONFIG_FILE}")"
    if [[ -n "${CHANNELS_CONFIG_BLOCK}" ]]; then
        if [[ -n "${CHANNELS_CONFIG_TOML}" ]]; then
            echo "WARN: channels_config_file ist gesetzt, channels_config_toml wird ignoriert." >&2
        fi
        CHANNELS_CONFIG_SOURCE="file:${CHANNELS_CONFIG_FILE}"
    elif [[ -n "${CHANNELS_CONFIG_TOML}" ]]; then
        echo "WARN: channels_config_file ist leer, fallback auf channels_config_toml." >&2
        CHANNELS_CONFIG_BLOCK="${CHANNELS_CONFIG_TOML}"
        CHANNELS_CONFIG_SOURCE="inline-fallback"
    fi
elif [[ -n "${CHANNELS_CONFIG_TOML}" ]]; then
    CHANNELS_CONFIG_BLOCK="${CHANNELS_CONFIG_TOML}"
    CHANNELS_CONFIG_SOURCE="inline"
fi

if [[ -n "${CHANNELS_CONFIG_BLOCK}" ]]; then
    append_managed_block "${CONFIG_FILE}" "${CHANNELS_CONFIG_BLOCK}"
    if ! /usr/local/bin/zeroclaw channel list >/dev/null 2>&1; then
        echo "ERROR: Channel-Konfiguration konnte nicht validiert werden." >&2
        echo "Pruefe channels_config_file/channels_config_toml (Syntax oder Feldnamen)." >&2
        exit 1
    fi
fi

chmod 600 "${CONFIG_FILE}" || true
export API_KEY
export PROVIDER
export ZEROCLAW_ALLOW_PUBLIC_BIND="${ALLOW_PUBLIC_BIND}"
export ZEROCLAW_GATEWAY_HOST="${GATEWAY_HOST}"
export ZEROCLAW_GATEWAY_PORT="${BACKEND_PORT}"

if [[ -n "${MODEL}" && "${MODEL}" != "null" ]]; then
    export ZEROCLAW_MODEL="${MODEL}"
fi

echo "=========================================="
echo "ZeroClaw Add-on"
echo "Provider: ${PROVIDER}"
echo "Runtime mode: ${RUNTIME_MODE}"
echo "Bind (backend): ${GATEWAY_HOST}:${BACKEND_PORT}"
echo "Require pairing: ${REQUIRE_PAIRING}"
if [[ -n "${CHANNELS_CONFIG_BLOCK}" ]]; then
    echo "Channels config: aktiv (${CHANNELS_CONFIG_SOURCE})"
else
    echo "Channels config: leer"
fi
echo "Ingress UI: http://0.0.0.0:${FRONTEND_PORT}/"
echo "=========================================="

primary_pid=""
case "${RUNTIME_MODE}" in
    gateway)
        /usr/local/bin/zeroclaw gateway &
        primary_pid="$!"
        ;;
    daemon)
        /usr/local/bin/zeroclaw daemon &
        primary_pid="$!"
        ;;
esac

nginx -c /etc/zeroclaw/nginx.conf -g "daemon off;" &
nginx_pid=$!

cleanup() {
    kill "${primary_pid}" "${nginx_pid}" >/dev/null 2>&1 || true
}

trap cleanup EXIT INT TERM

set +e
wait -n "${primary_pid}" "${nginx_pid}"
exit_code=$?
set -e
cleanup
exit "${exit_code}"
