#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE="/data/options.json"
DEFAULT_STATE_DIR="/data/zeroclaw"
STATE_DIR="${DEFAULT_STATE_DIR}"
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

resolve_path() {
    local value="$1"
    if [[ "${value}" != /* ]]; then
        echo "/share/${value}"
        return
    fi
    echo "${value}"
}

dir_has_entries() {
    local dir="$1"
    if [[ ! -d "${dir}" ]]; then
        return 1
    fi
    find "${dir}" -mindepth 1 -maxdepth 1 -print -quit | grep -q .
}

API_KEY="$(read_opt '.api_key' '')"
PROVIDER="$(read_opt '.provider' 'openrouter')"
MODEL="$(read_opt '.model' '')"
PERSISTENT_DATA_DIR="$(read_opt '.persistent_data_dir' '')"

if [[ -z "${API_KEY}" ]]; then
    echo "ERROR: Option 'api_key' fehlt oder ist leer." >&2
    exit 1
fi

if [[ "${PERSISTENT_DATA_DIR}" == "null" ]]; then
    PERSISTENT_DATA_DIR=""
fi
if [[ -n "${PERSISTENT_DATA_DIR}" ]]; then
    STATE_DIR="$(resolve_path "${PERSISTENT_DATA_DIR}")"
    STATE_DIR="${STATE_DIR%/}"
fi

mkdir -p "${STATE_DIR}"
if [[ "${STATE_DIR}" != "${DEFAULT_STATE_DIR}" ]]; then
    if dir_has_entries "${DEFAULT_STATE_DIR}" && ! dir_has_entries "${STATE_DIR}"; then
        cp -a "${DEFAULT_STATE_DIR}/." "${STATE_DIR}/"
        echo "INFO: Persistente Daten von ${DEFAULT_STATE_DIR} nach ${STATE_DIR} migriert." >&2
    fi
fi

mkdir -p "${STATE_DIR}/.zeroclaw" "${STATE_DIR}/workspace"

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

CHANNELS_CONFIG_BLOCK=""
CHANNELS_CONFIG_SOURCE=""
CHANNELS_CONFIG_FILE="${STATE_DIR}/channels.toml"
if [[ ! -f "${CHANNELS_CONFIG_FILE}" ]]; then
    cat > "${CHANNELS_CONFIG_FILE}" <<'EOF'
# ZeroClaw channels config
# Fill this file with your channel definitions.
#
# Example:
# [channels_config.discord]
# bot_token = "discord-bot-token"
# guild_id = "123456789012345678"
# allowed_users = ["123456789012345678"]
# listen_to_bots = false
# mention_only = false
EOF
    echo "INFO: Beispiel-Datei erstellt: ${CHANNELS_CONFIG_FILE}" >&2
fi
CHANNELS_CONFIG_BLOCK="$(cat "${CHANNELS_CONFIG_FILE}")"
if [[ -n "${CHANNELS_CONFIG_BLOCK}" ]]; then
    CHANNELS_CONFIG_SOURCE="file:${CHANNELS_CONFIG_FILE}"
else
    echo "WARN: ${CHANNELS_CONFIG_FILE} ist leer. Keine Channel-Konfiguration wird geladen." >&2
fi

if [[ -n "${CHANNELS_CONFIG_BLOCK}" ]]; then
    append_managed_block "${CONFIG_FILE}" "${CHANNELS_CONFIG_BLOCK}"
    if ! /usr/local/bin/zeroclaw channel list >/dev/null 2>&1; then
        echo "ERROR: Channel-Konfiguration konnte nicht validiert werden." >&2
        echo "Pruefe ${CHANNELS_CONFIG_FILE} (Syntax oder Feldnamen)." >&2
        exit 1
    fi
fi

chmod 600 "${CONFIG_FILE}" || true
export API_KEY
export PROVIDER

if [[ -n "${MODEL}" && "${MODEL}" != "null" ]]; then
    export ZEROCLAW_MODEL="${MODEL}"
fi

echo "=========================================="
echo "ZeroClaw Add-on"
echo "Provider: ${PROVIDER}"
echo "Runtime mode: daemon"
echo "State dir: ${STATE_DIR}"
if [[ -n "${CHANNELS_CONFIG_BLOCK}" ]]; then
    echo "Channels config: aktiv (${CHANNELS_CONFIG_SOURCE})"
else
    echo "Channels config: leer"
fi
echo "=========================================="
exec /usr/local/bin/zeroclaw daemon
