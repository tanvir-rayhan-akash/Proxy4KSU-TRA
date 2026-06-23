# Proxy4KSU — TRA Edition

<div align="center">

![Version](https://img.shields.io/badge/version-v3.5.1--TRA-blue)
![Author](https://img.shields.io/badge/author-TRA%20–%20Tanvir%20Rayhan%20Akash-green)
![Platform](https://img.shields.io/badge/platform-KernelSU%20%7C%20Magisk-orange)
![Android](https://img.shields.io/badge/android-12%2B-brightgreen)

**A fully optimized KernelSU/Magisk proxy module — built for maximum speed, stability, and smart network switching.**

</div>

---

## ✨ Features

- ⚡ **Data ON → Core ON in ≤2 seconds**
- 📴 **Data OFF → Core OFF automatically**
- 📶 **WiFi connected → Core OFF** (no waste)
- 🔄 **Crash auto-recovery** with backoff protection
- 🛡️ **Debounce protection** — no flapping/unstable restarts
- 🌐 **DoH DNS** (Cloudflare + Google) — ISP DNS bypass
- 🚀 **TCP Fast Open + No Delay** across all cores
- 🔋 **Battery-friendly** adaptive polling (0.5s fast / 2s idle)
- 📦 Supports: **Xray · V2Ray · Sing-box · Mihomo · Hysteria2**

---

## 📱 Requirements

- KernelSU or Magisk (latest)
- Android 12 or above (Android 16 optimized)
- ARM64 or x64 device

---

## 📥 Install

1. Download the latest `.zip` from [Releases](../../releases)
2. Open **KernelSU** or **Magisk** → Modules → Install from storage
3. Select the zip → Follow on-screen instructions
4. Choose your core type (Xray recommended)
5. Reboot

> **No volume keys?** Create `/sdcard/proxy4ksu.setup`:
> - Line 1: core type (`xray` / `v2ray` / `sing-box` / `mihomo` / `hysteria2`)
> - Line 2: `keep` (preserve old config) or leave blank (overwrite)
> - Line 3: WebUI type (`1` = yacd-meta, `2` = metacubexd)

---

## ⚙️ Configuration

| File | Location |
|------|----------|
| Main helper config | `/data/adb/xray/xrayhelper.yml` |
| Xray configs | `/data/adb/xray/confs/*.json` |
| V2Ray config | `/data/adb/xray/v2rayconfs/config.json` |
| Sing-box configs | `/data/adb/xray/singconfs/*.json` |
| Mihomo template | `/data/adb/xray/mihomoconfs/template.yaml` |
| Hysteria2 config | `/data/adb/xray/hy2confs/config.yaml` |

### Key settings in `xrayhelper.yml`

```yaml
proxy:
    stopWhenWifi: true     # WiFi তে core বন্ধ থাকবে
    mode: blacklist        # blacklist = সব traffic proxy, বাদে listed apps
```

---

## 🔄 Network Behavior

| Network State | Core |
|--------------|------|
| 📶 Mobile Data ON | ✅ Starts within ~1.5s |
| 📴 Mobile Data OFF | ❌ Stops immediately |
| 📡 WiFi Connected | ❌ Off (stopWhenWifi=true) |
| ❌ No Network | ❌ Off |

---

## 🗂️ File Structure

```
Proxy4KSU-TRA/
├── META-INF/                  # Magisk/KernelSU installer
├── module.prop                # Module info
├── customize.sh               # Install script
├── proxy4ksu_service.sh       # Boot service
├── uninstall.sh               # Uninstall cleaner
├── webroot/                   # Web UI dashboard
└── xray/
    ├── etc/
    │   ├── confs/             # Xray config (base, dns, routing, policy, proxy)
    │   ├── singconfs/         # Sing-box config
    │   ├── v2rayconfs/        # V2Ray config
    │   ├── mihomoconfs/       # Mihomo/Clash template
    │   ├── hy2confs/          # Hysteria2 config
    │   └── xrayhelper.yml     # Master config
    └── scripts/
        ├── start.sh           # Boot startup script
        ├── net_monitor.sh     # Network state monitor (primary)
        ├── net.inotify        # inotify-based trigger (fallback)
        └── xray.inotify       # Module enable/disable watcher
```

---

## 🛠️ TRA Optimizations

### Scripts
- `net_monitor.sh` — Debounce (2x confirm), crash backoff (max 5 retry → 30s pause), adaptive polling
- `net.inotify` — Consistent logic with monitor, lock-protected concurrent trigger
- `start.sh` — Fast boot, 2s post-boot settle, clean log output
- `proxy4ksu_service.sh` — Boot-complete wait + system settle

### Xray Config
- `bufferSize: 16384` — large packet handling
- `tcpFastOpen + tcpNoDelay` — low latency
- `tcpKeepAliveIdle: 300` — stable long connections
- `IPIfNonMatch` routing — accurate domain resolution

### DNS
- Primary: **DoH** (`https://1.1.1.1/dns-query`) — ISP interference bypass
- Fallback: `1.1.1.1` → `8.8.8.8` — 4-layer chain
- Mihomo: **fake-ip mode** + DoH nameservers

### Hysteria2
- Bandwidth: `50mbps up / 200mbps down`
- `fastOpen: true`, `lazy: false`

---

## ⚠️ Disclaimer

This module is provided as-is. I am not responsible for bricked devices, bootloops, or any damage caused by misconfiguration.

**Make sure your proxy config does not cause traffic loops — this can cause continuous reboots.**

---

## 🙏 Credits

- Original module: [nhAsif/Proxy4KSU](https://github.com/nhAsif/Proxy4KSU)
- TRA Edition optimization: **TRA — Tanvir Rayhan Akash**

---

<div align="center">
Made with ❤️ by <strong>TRA — Tanvir Rayhan Akash</strong>
</div>
