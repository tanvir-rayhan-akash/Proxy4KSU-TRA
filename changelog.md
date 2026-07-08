## v6.69-TRA

### Performance & Stability
- Tuned `policy.json`: reduced `connIdle` (300s → 180s) for faster stale-connection cleanup on mobile data ↔ WiFi switch
- Increased per-connection `bufferSize` (512KB → 4096KB) for improved throughput on high-latency routes
- Added explicit `sockopt` tuning (`tcpFastOpen`, `tcpNoDelay`, `mark`) to the `proxy` outbound in `proxy.json` for consistency with the inbound leg

### Notes
- Core proxy method remains `tproxy` — evaluated `tun`/`tun2socks`, confirmed `tproxy` is faster on rooted (KernelSU) devices
