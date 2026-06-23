#!/system/bin/sh
# start.sh - TRA Edition v3.5.0
# Author: TRA - Tanvir Rayhan Akash
# Fast boot, stable startup, Android 16 optimized

MOD_DIR=/data/adb/modules/proxy4ksu
NET_DIR=/data/misc/net
SCRIPTS_DIR=/data/adb/xray/scripts
XRAYHELPER=/data/adb/xray/bin/xrayhelper
XRAYHELPER_CONF=/data/adb/xray/xrayhelper.yml
RUN_DIR=/data/adb/xray/run

# ── Log helper ──
log() { echo "[TRA-start] $1 [$(date '+%H:%M:%S')]"; }

log "Boot sequence initiated"

# ── Stale file cleanup ──
rm -f "${RUN_DIR}/core.pid"
rm -f "${RUN_DIR}/adghome.pid"
rm -f "${RUN_DIR}/tun2socks.pid"
rm -f "${RUN_DIR}/net_restart.lock"
log "Cleaned stale files"

if [ ! -f /data/adb/xray/manual ]; then
    # xrayhelper init
    ${XRAYHELPER} >/data/adb/xray/run/helper.log 2>&1
    log "xrayhelper initialized"

    # Module enable/disable toggle watcher
    inotifyd "${SCRIPTS_DIR}/xray.inotify" "${MOD_DIR}" \
        >>/data/adb/xray/run/helper.log 2>&1 &

    # Network change watcher (Android < 16 fallback)
    inotifyd "${SCRIPTS_DIR}/net.inotify" "${NET_DIR}" \
        >>/data/adb/xray/run/helper.log 2>&1 &

    # Primary network monitor (Android 16, 2s idle / 0.5s fast poll)
    "${SCRIPTS_DIR}/net_monitor.sh" >> /data/adb/xray/run/monitor.log 2>&1 &
    log "Monitor started (pid=$!)"

    if [ ! -f "${MOD_DIR}/disable" ]; then
        # Fast interface wait: 0.3s poll, max 3s (10 tries)
        waited=0
        while [ "$waited" -lt 10 ]; do
            iface=$(ip route get 1.1.1.1 2>/dev/null \
                    | grep -o 'dev [^ ]*' | awk '{print $2}')
            if [ -n "$iface" ]; then
                log "Network ready on: $iface"
                break
            fi
            sleep 0.3
            waited=$((waited + 1))
        done

        # Trigger initial net.inotify to start core immediately
        "${SCRIPTS_DIR}/net.inotify" w &
        log "Initial trigger sent"
    fi
fi

log "Start sequence complete"
