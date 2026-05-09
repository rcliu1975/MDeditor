#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UNIT_SRC_DIR="${ROOT_DIR}/systemd/user"
UNIT_DST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

usage() {
  cat <<'EOF'
Usage: mdeditor-systemd-user.sh <install|uninstall|start|stop|restart|status|logs|route-dns>

Commands:
  install    Install user units and enable them immediately
  uninstall  Disable and remove user units
  start      Start MDeditor services
  stop       Stop MDeditor services
  restart    Restart MDeditor services
  status     Show service status
  logs       Show recent service logs
  route-dns  Ensure Cloudflare Tunnel DNS route exists
EOF
}

require_cloudflared() {
  if [[ ! -x "$HOME/bin/cloudflared" ]]; then
    echo "cloudflared not found at $HOME/bin/cloudflared" >&2
    exit 1
  fi
}

route_dns() {
  require_cloudflared
  local output
  if output="$("$HOME/bin/cloudflared" tunnel route dns mdeditor_kennylab-tunnel MDeditor.kennylab.online 2>&1)"; then
    printf '%s\n' "$output"
    return 0
  fi

  if grep -Fq 'with that host already exists' <<<"$output"; then
    printf '%s\n' "$output"
    echo "DNS route already exists; continuing."
    return 0
  fi

  printf '%s\n' "$output" >&2
  return 1
}

install_units() {
  mkdir -p "${UNIT_DST_DIR}"
  install -m 0644 "${UNIT_SRC_DIR}/mdeditor-http.service" "${UNIT_DST_DIR}/mdeditor-http.service"
  install -m 0644 "${UNIT_SRC_DIR}/mdeditor-cloudflared.service" "${UNIT_DST_DIR}/mdeditor-cloudflared.service"
  install -m 0644 "${UNIT_SRC_DIR}/mdeditor.target" "${UNIT_DST_DIR}/mdeditor.target"
  systemctl --user daemon-reload
}

case "${1:-}" in
  install)
    route_dns
    install_units
    systemctl --user enable --now mdeditor.target
    ;;
  uninstall)
    systemctl --user disable --now mdeditor.target mdeditor-cloudflared.service mdeditor-http.service || true
    rm -f \
      "${UNIT_DST_DIR}/mdeditor.target" \
      "${UNIT_DST_DIR}/mdeditor-cloudflared.service" \
      "${UNIT_DST_DIR}/mdeditor-http.service"
    systemctl --user daemon-reload
    ;;
  start)
    systemctl --user start mdeditor.target
    ;;
  stop)
    systemctl --user stop mdeditor.target
    ;;
  restart)
    systemctl --user restart mdeditor.target
    ;;
  status)
    systemctl --user status mdeditor.target mdeditor-http.service mdeditor-cloudflared.service
    ;;
  logs)
    journalctl --user -u mdeditor-http.service -u mdeditor-cloudflared.service -n 100 --no-pager
    ;;
  route-dns)
    route_dns
    ;;
  *)
    usage
    exit 1
    ;;
esac
