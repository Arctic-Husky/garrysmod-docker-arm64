#!/usr/bin/env bash
set -euo pipefail

# Use array for extra args to avoid quoting bugs
ARGS=()

if [ -n "${NAME:-}" ]; then
    ARGS+=( "+hostname" "${NAME}" )
fi

if [ -n "${GSLT:-}" ]; then
    ARGS+=( "+sv_setsteamaccount" "${GSLT}" )
fi

if [ -n "${AUTHKEY:-}" ]; then
    ARGS+=( "-authkey" "${AUTHKEY}" )
fi

if [ -n "${PRODUCTION:-}" ] && [ "${PRODUCTION}" -ne 0 ]; then
    MODE="production"
    # no lua refresh in production
    BASE_ARGS=( -disableluarefresh )
else
    MODE="development"
    BASE_ARGS=( -gdb gdb -debug )
fi

echo "Starting server on ${MODE} mode..."

echo | pwd

# export LD_LIBRARY_PATH=".:/home/steam/steamcmd/linux32/:bin:$LD_LIBRARY_PATH"

# Explicitly quote every variable and expand ARGS as array
exec "/home/steam/server/srcds_run" \
    -game "garrysmod" \
    -binary "/home/steam/server/srcds_box64_wrapper" \
    -ip "0.0.0.0" \
    -norestart \
    -strictportbind \
    -autoupdate \
    -steam_dir "/home/steam/steamcmd" \
    -steamcmd_script "/home/steam/update.txt" \
    -port "${PORT:-27015}" \
    -maxplayers "${MAXPLAYERS:-12}" \
    +gamemode "${GAMEMODE:-sandbox}" \
    +sv_lan 0 \
    +map "${MAP:-gm_construct}" \
    "${BASE_ARGS[@]}" \
    "${ARGS[@]}"
