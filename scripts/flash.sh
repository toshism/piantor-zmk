#!/usr/bin/env bash
# Wait-for-bootloader flasher for the Piantor Pro BT (ZMK / nRF52840 UF2).
#
# Run this FIRST, THEN put the half into bootloader mode (hold left-pinky Esc + V).
# It polls for the KEEBART drive, mounts it, copies the firmware, and exits -
# so you don't need the keyboard to work during the flash (mimics `qmk flash`).
#
# Usage:
#   scripts/flash.sh              # left / central half (default, for keymap changes)
#   scripts/flash.sh right        # right / peripheral half
#   scripts/flash.sh reset        # settings-reset (wipes BT bonds) on the left half
#   scripts/flash.sh path/to.uf2  # any explicit .uf2
#
# Env overrides: LABEL=KEEBART  TIMEOUT=120 (seconds)
set -euo pipefail

LABEL="${LABEL:-KEEBART}"
TIMEOUT="${TIMEOUT:-120}"

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
fw_dir="$repo_root/firmware"

case "${1:-left}" in
  left)                 FW="$fw_dir/nice_view-piantor_pro_bt_left-zmk.uf2" ;;
  right)                FW="$fw_dir/nice_view-piantor_pro_bt_right-zmk.uf2" ;;
  reset|settings-reset) FW="$fw_dir/settings_reset-piantor_pro_bt_left-zmk.uf2" ;;
  *)                    FW="$1" ;;
esac

if [[ ! -f "$FW" ]]; then
  echo "Firmware not found: $FW" >&2
  exit 1
fi

echo "Firmware : $FW"
echo "Waiting for '$LABEL' bootloader (up to ${TIMEOUT}s)..."
echo ">> Now put the half into bootloader: hold left-pinky (Esc) + V."

dev=""
for _ in $(seq 1 $(( TIMEOUT * 2 ))); do
  if [[ -e "/dev/disk/by-label/$LABEL" ]]; then
    dev="$(readlink -f "/dev/disk/by-label/$LABEL")"
    break
  fi
  sleep 0.5
done

if [[ -z "$dev" ]]; then
  echo "Timed out waiting for '$LABEL'." >&2
  echo "If the drive has a different label, find it with:" >&2
  echo "  lsblk -o NAME,LABEL,SIZE,TYPE,MOUNTPOINT" >&2
  echo "then re-run with LABEL=<that label> scripts/flash.sh" >&2
  exit 1
fi

echo "Detected bootloader at $dev"

# Use an existing mount if udisks/GNOME auto-mounted it; otherwise mount it.
mnt="$(findmnt -nro TARGET "$dev" 2>/dev/null || true)"
if [[ -z "$mnt" ]]; then
  out="$(udisksctl mount -b "$dev")"   # -> "Mounted /dev/sdX at /run/media/.../KEEBART"
  mnt="${out##* at }"
  mnt="${mnt%.}"                        # strip a trailing period if present
fi
echo "Mounted at $mnt"

# The bootloader reboots the instant it has the full image, so cp/sync often
# error out with "device disconnected" - that is SUCCESS, not failure.
echo "Flashing..."
cp "$FW" "$mnt/" 2>/dev/null || true
sync 2>/dev/null || true

echo "Done - the board should reboot with the new firmware."
