# Changelog — Proxy4KSU TRA Edition

## v3.6.0-TRA (2026-07-04) — Turbo Speed Update

**Focus: throughput + reconnect latency, VLESS/TLS/TCP tuned**

### Core (xray/sing-box configs)
- Enabled BBR congestion control on proxy-in, socks-in, and direct outbound sockets
- Raised TCP Fast Open queue length (4096) on the transparent proxy inbound
- Tightened keep-alive timers (idle 300s→120s, interval 60s→30s) for quicker dead-connection detection
- Increased policy buffer size (512→2048) for better bulk-transfer throughput
- Reduced connection idle timeout (300s→180s) to free up sockets faster
- DNS: enabled fallback skipping on DoH servers + disabled redundant fallback matching for faster resolution
- sing-box: added UDP fragmentation support, trimmed UDP timeout (300s→180s)

### Scripts (boot & reconnect speed)
- `net.inotify`: network-settle delay cut 1s → 0.4s
- `start.sh`: interface-ready poll tightened 0.3s → 0.2s (max wait 3s → 2s)
- `net_monitor.sh`: fast-poll cycle 0.5s → 0.3s; effective reconnect time ~2s → ~1.2s

### Config
- `autoDNSStrategy` enabled in `xrayhelper.yml` for adaptive IPv4/IPv6 resolution

### Notes
- All existing features (net monitor states, wifi policy, manual mode, multi-core support) preserved unchanged
- No changes to xrayhelper binary (upstream compiled component) — this release only tunes configs and orchestration scripts around it

## v3.5.1-TRA (2026-06-23)
- Previous release baseline
