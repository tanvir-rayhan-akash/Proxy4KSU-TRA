#!/system/bin/sh
# proxy4ksu_service.sh - TRA Edition v3.5.0
# Author: TRA - Tanvir Rayhan Akash

(
    # Boot complete হওয়া পর্যন্ত অপেক্ষা করো (5s interval)
    until [ "$(getprop sys.boot_completed)" = "1" ]; do
        sleep 5
    done

    # Boot এর পরে আরও 2s wait — system settle হওয়ার জন্য
    sleep 2

    /data/adb/xray/scripts/start.sh
) &
