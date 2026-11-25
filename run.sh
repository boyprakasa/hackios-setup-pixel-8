#!/usr/bin/env bash
# Usage:
#   ./run.sh all   [WORKSPACE_DIR] [EXISTING_SHIBA_CLONE_DIR]   # sekali jalan: workspace+deps+prep+build+boot
#   ./run.sh workspace [WORKSPACE_DIR] [EXISTING_SHIBA_CLONE_DIR]
#   ./run.sh deps|prep|build|boot [WORKSPACE_DIR]
#
# WORKSPACE_DIR default: ~/Projects/Pixel/hakios
# EXISTING_SHIBA_CLONE_DIR: path clone hackios-devices-shiba lama (kalau ada),
#   otomatis terdeteksi di ~/Projects/Pixel/hackios-devices-shiba kalau tidak dikasih.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEP="${1:-all}"
shift || true

DEFAULT_WORKSPACE="$HOME/Projects/Pixel/hakios"

run_in_workspace() {
  local ws="$1"; shift
  echo "== Menjalankan di workspace: $ws =="
  cd "$ws"
  for script in "$@"; do
    bash "$SCRIPT_DIR/$script"
  done
}

case "$STEP" in
  workspace)
    bash "$SCRIPT_DIR/00-setup-workspace.sh" "$@"
    ;;
  deps)
    WORKSPACE="${1:-$DEFAULT_WORKSPACE}"
    run_in_workspace "$WORKSPACE" 01-install-deps.sh
    ;;
  prep)
    WORKSPACE="${1:-$DEFAULT_WORKSPACE}"
    run_in_workspace "$WORKSPACE" 02-prep-device.sh
    ;;
  build)
    WORKSPACE="${1:-$DEFAULT_WORKSPACE}"
    run_in_workspace "$WORKSPACE" 03-build.sh
    ;;
  boot)
    WORKSPACE="${1:-$DEFAULT_WORKSPACE}"
    run_in_workspace "$WORKSPACE" 04-boot.sh
    ;;
  all)
    WORKSPACE="${1:-$DEFAULT_WORKSPACE}"
    EXISTING_CLONE="${2:-}"
    echo "== Tahap 0: siapkan workspace =="
    bash "$SCRIPT_DIR/00-setup-workspace.sh" "$WORKSPACE" "$EXISTING_CLONE"
    run_in_workspace "$WORKSPACE" 01-install-deps.sh 02-prep-device.sh 03-build.sh 04-boot.sh
    ;;
  *)
    echo "Usage: $0 [all|workspace|deps|prep|build|boot] [WORKSPACE_DIR] [EXISTING_SHIBA_CLONE_DIR]"
    exit 1
    ;;
esac