#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UNIT_SRC_DIR="${ROOT_DIR}/systemd/user"
UNIT_DST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

usage() {
  cat <<'EOF'
Usage: mdeditor-systemd-user.sh <install|uninstall|start|stop|restart|status|logs>

Commands:
  install    Install user units and enable them immediately
  uninstall  Disable and remove user units
  start      Start MDeditor services
  stop       Stop MDeditor services
  restart    Restart MDeditor services
  status     Show service status
  logs       Show recent service logs
EOF
}

install_units() {
  mkdir -p "${UNIT_DST_DIR}"
  install -m 0644 "${UNIT_SRC_DIR}/mdeditor-http.service" "${UNIT_DST_DIR}/mdeditor-http.service"
  install -m 0644 "${UNIT_SRC_DIR}/mdeditor.target" "${UNIT_DST_DIR}/mdeditor.target"
  rm -f "${UNIT_DST_DIR}/mdeditor-cloudflared.service"
  systemctl --user daemon-reload
}

case "${1:-}" in
  install)
    systemctl --user disable --now mdeditor-cloudflared.service 2>/dev/null || true
    install_units
    systemctl --user enable --now mdeditor.target
    ;;
  uninstall)
    systemctl --user disable --now mdeditor.target mdeditor-http.service mdeditor-cloudflared.service 2>/dev/null || true
    rm -f \
      "${UNIT_DST_DIR}/mdeditor.target" \
      "${UNIT_DST_DIR}/mdeditor-http.service" \
      "${UNIT_DST_DIR}/mdeditor-cloudflared.service"
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
    systemctl --user status mdeditor.target mdeditor-http.service
    ;;
  logs)
    journalctl --user -u mdeditor-http.service -n 100 --no-pager
    ;;
  *)
    usage
    exit 1
    ;;
esac
