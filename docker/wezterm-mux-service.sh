#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="/etc/wezterm/wezterm-mux.lua"
SOCKET_DIR="/run/wezterm"
SOCKET_PATH="$SOCKET_DIR/wezterm-mux.sock"
BRIDGE_HOST="127.0.0.1"
BRIDGE_PORT="22350"

log() {
	printf '[wezterm-mux-service] %s\n' "$*" >&2
}

listener_ready() {
	if command -v ss >/dev/null 2>&1; then
		ss -ltn 2>/dev/null | grep -Eq "${BRIDGE_HOST}:${BRIDGE_PORT}"
		return $?
	fi
	if command -v netstat >/dev/null 2>&1; then
		netstat -ltn 2>/dev/null | grep -Eq "${BRIDGE_HOST}:${BRIDGE_PORT}"
		return $?
	fi
	return 1
}

socket_ready() {
	[[ -S "$SOCKET_PATH" ]]
}

ensure_config_file() {
	mkdir -p /etc/wezterm
	if [[ -s "$CONFIG_FILE" ]]; then
		return 0
	fi

	cat >"$CONFIG_FILE" <<'EOF'
local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.unix_domains = {
  {
    name = "unix",
    socket_path = "/run/wezterm/wezterm-mux.sock",
    no_serve_automatically = true,
  },
}

config.daemon_options = {
  pid_file = "/run/wezterm-mux-server.pid",
}

return config
EOF
}

cleanup() {
	if [[ -n "${socat_pid:-}" ]] && kill -0 "$socat_pid" >/dev/null 2>&1; then
		kill "$socat_pid" >/dev/null 2>&1 || true
	fi
	if [[ -n "${mux_pid:-}" ]] && kill -0 "$mux_pid" >/dev/null 2>&1; then
		kill "$mux_pid" >/dev/null 2>&1 || true
	fi
}

trap cleanup INT TERM

mkdir -p "$SOCKET_DIR"
rm -f "$SOCKET_PATH"

ensure_config_file

log "starting wezterm-mux-server on unix socket $SOCKET_PATH"
wezterm-mux-server --config-file "$CONFIG_FILE" &
mux_pid=$!

for _ in $(seq 1 20); do
	if ! kill -0 "$mux_pid" >/dev/null 2>&1; then
		wait "$mux_pid"
		exit $?
	fi
	if socket_ready; then
		break
	fi
	sleep 1
done

if ! socket_ready; then
	log "unix socket failed to become ready at $SOCKET_PATH"
	cleanup
	wait "$mux_pid" >/dev/null 2>&1 || true
	exit 1
fi

log "starting socat bridge ${BRIDGE_HOST}:${BRIDGE_PORT} -> UNIX:$SOCKET_PATH"
socat "TCP-LISTEN:${BRIDGE_PORT},bind=${BRIDGE_HOST},reuseaddr,fork" "UNIX-CONNECT:${SOCKET_PATH}" &
socat_pid=$!

for _ in $(seq 1 20); do
	if ! kill -0 "$mux_pid" >/dev/null 2>&1; then
		wait "$mux_pid"
		exit $?
	fi
	if ! kill -0 "$socat_pid" >/dev/null 2>&1; then
		wait "$socat_pid"
		exit $?
	fi
	if listener_ready; then
		log "bridge listener ready on ${BRIDGE_HOST}:${BRIDGE_PORT}"
		break
	fi
	sleep 1
done

if ! listener_ready; then
	log "bridge listener failed to become ready on ${BRIDGE_HOST}:${BRIDGE_PORT}"
	cleanup
	wait "$mux_pid" >/dev/null 2>&1 || true
	wait "$socat_pid" >/dev/null 2>&1 || true
	exit 1
fi

while true; do
	if ! kill -0 "$mux_pid" >/dev/null 2>&1; then
		wait "$mux_pid"
		exit $?
	fi
	if ! kill -0 "$socat_pid" >/dev/null 2>&1; then
		wait "$socat_pid"
		exit $?
	fi
	sleep 2
done
