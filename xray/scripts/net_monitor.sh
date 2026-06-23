#!/system/bin/sh
# net_monitor.sh - TRA Edition v3.5.1
# Author: TRA - Tanvir Rayhan Akash
#
# BEHAVIOR:
#   • Data ON  → core ON  (≤2s)
#   • Data OFF → core OFF
#   • WiFi ON  → core OFF (stopWhenWifi=true)
#   • No net   → core OFF

xrayhelper=/data/adb/xray/bin/xrayhelper
xrayhelper_conf=/data/adb/xray/xrayhelper.yml
mod_dir=/data/adb/modules/proxy4ksu
run_dir=/data/adb/xray/run

# ─── Helpers ────────────────────────────────────────────────────────

stop_when_wifi_enabled() {
    grep -q 'stopWhenWifi:[[:space:]]*true' "${xrayhelper_conf}" 2>/dev/null
}

# Net state: routing table দিয়ে — সবচেয়ে reliable method
get_net_state() {
    local dev
    dev=$(ip route get 1.1.1.1 2>/dev/null | grep -o 'dev [^ ]*' | awk '{print $2}')
    [ -z "$dev" ] && { echo "none"; return; }
    case "$dev" in
        wlan*|wifi*|swlan*|ap+*)     echo "wifi" ;;
        rmnet*|ccmni*|wwan*|rndis*) echo "mobile" ;;
        *)                           echo "other" ;;
    esac
}

core_running() {
    local pid
    pid=$(cat "${run_dir}/core.pid" 2>/dev/null)
    [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

log_msg() {
    echo "[TRA] $1 [$(date '+%H:%M:%S')]"
}

stop_xray() {
    log_msg "STOP ← $1"
    "${xrayhelper}" -c "${xrayhelper_conf}" proxy disable 2>/dev/null
    "${xrayhelper}" -c "${xrayhelper_conf}" service stop 2>/dev/null
}

start_xray() {
    if core_running; then
        log_msg "SKIP ← already running [$1]"
        return 0
    fi
    log_msg "START → $1"
    "${xrayhelper}" -c "${xrayhelper_conf}" service start && \
        "${xrayhelper}" -c "${xrayhelper_conf}" proxy enable
}

# ─── State Handler ─────────────────────────────────────────────────
# সহজ clear logic:
#   mobile → START
#   wifi   → STOP (stopWhenWifi=true হলে), START (false হলে)
#   none   → STOP
#   other  → START (tethering/ethernet)

handle_state() {
    local cur="$1"
    case "$cur" in
        mobile|other)
            start_xray "$cur"
            ;;
        wifi)
            if stop_when_wifi_enabled; then
                # WiFi তে core বন্ধ রাখো
                core_running && stop_xray "wifi-policy"
            else
                # WiFi তেও চালু রাখো
                start_xray "wifi"
            fi
            ;;
        none)
            core_running && stop_xray "no-net"
            ;;
    esac
}

# ─── Main Loop ─────────────────────────────────────────────────────
# Target: Data ON হলে ≤2s এর মধ্যে core চালু
#
# Timing breakdown:
#   debounce=2, poll=0.5s → confirm পেতে 1s
#   start_xray → ~0.5-1s
#   Total: ~1.5-2s ✓
#
# Idle (stable state): 2s poll — battery friendly

monitor_loop() {
    local prev_state=""
    local fast_cycles=0
    local debounce_state=""
    local debounce_count=0
    local crash_backoff=0
    local DEBOUNCE_MIN=2   # 2×0.5s = 1s confirm time → total ≤2s startup

    log_msg "Monitor started (pid=$$)"

    while true; do
        # Manual mode বা module disabled
        if [ -f /data/adb/xray/manual ] || [ -f "${mod_dir}/disable" ]; then
            prev_state=""
            debounce_state=""
            debounce_count=0
            fast_cycles=0
            crash_backoff=0
            sleep 3
            continue
        fi

        local cur_state
        cur_state=$(get_net_state)

        # ── Debounce: unstable/flapping state ignore ──
        if [ "$cur_state" = "$debounce_state" ]; then
            debounce_count=$((debounce_count + 1))
        else
            debounce_state="$cur_state"
            debounce_count=1
        fi

        if [ "$debounce_count" -ge "$DEBOUNCE_MIN" ]; then
            if [ "$cur_state" != "$prev_state" ]; then
                # State change → handle করো
                log_msg "[$((debounce_count))x] ${prev_state:-boot} → ${cur_state}"
                prev_state="$cur_state"
                fast_cycles=8
                crash_backoff=0
                handle_state "$cur_state"
            else
                # State same — core crash হলে restart (backoff সহ)
                if [ "$cur_state" != "none" ] && ! core_running; then
                    # WiFi তে stopWhenWifi=true → crash restart করবো না
                    if [ "$cur_state" = "wifi" ] && stop_when_wifi_enabled; then
                        : # intentionally off, skip
                    else
                        crash_backoff=$((crash_backoff + 1))
                        if [ "$crash_backoff" -le 5 ]; then
                            log_msg "CRASH-RESTART #${crash_backoff} [${cur_state}]"
                            handle_state "$cur_state"
                            fast_cycles=6
                        else
                            log_msg "CRASH-LIMIT: pause 30s"
                            sleep 30
                            crash_backoff=0
                        fi
                    fi
                else
                    crash_backoff=0
                fi
            fi
        fi

        # ── Adaptive polling ──
        if [ "$fast_cycles" -gt 0 ]; then
            fast_cycles=$((fast_cycles - 1))
            sleep 0.5   # change এর পর: 0.5s fast poll
        else
            sleep 2     # stable: 2s idle poll
        fi
    done
}

monitor_loop
