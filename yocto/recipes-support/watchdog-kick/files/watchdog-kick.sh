#!/bin/sh
set -eu

WATCHDOG_DEVICE="${WATCHDOG_DEVICE:-}"
WATCHDOG_BASE_ADDR="${WATCHDOG_BASE_ADDR:-0x14c37400}"
WATCHDOG_INTERVAL="${WATCHDOG_INTERVAL:-10}"

find_watchdog_device() {
  local base_addr="${1#0x}"
  local wdt_dir reg_path reg_words word

  for wdt_dir in /sys/class/watchdog/watchdog*; do
    reg_path="$wdt_dir/device/of_node/reg"
    if [ -r "$reg_path" ]; then
      reg_words=$(od -An -tx4 -v "$reg_path" 2>/dev/null)
      for word in $reg_words; do
        if [ "$word" = "$base_addr" ]; then
          echo "/dev/$(basename "$wdt_dir")"
          return 0
        fi
      done
    fi
  done

  return 1
}

if [ -z "$WATCHDOG_DEVICE" ]; then
  WATCHDOG_DEVICE="$(find_watchdog_device "$WATCHDOG_BASE_ADDR" || true)"
fi

if [ -z "$WATCHDOG_DEVICE" ] || [ ! -e "$WATCHDOG_DEVICE" ]; then
  echo "watchdog-kick: device not found for base address $WATCHDOG_BASE_ADDR" >&2
  exit 1
fi

case "$WATCHDOG_INTERVAL" in
  ''|*[!0-9]*)
    echo "watchdog-kick: invalid interval: $WATCHDOG_INTERVAL" >&2
    exit 1
    ;;
  0)
    echo "watchdog-kick: interval must be > 0" >&2
    exit 1
    ;;
  *)
    ;;
esac

exec 3>"$WATCHDOG_DEVICE"

while true; do
  printf 'K' >&3
  sleep "$WATCHDOG_INTERVAL"
done
