# Changelog

## v3.5.1-TRA (2026-06-23)

### Fixed
- **Network drop race condition**: Fixed periodic network drops caused by two concurrent network monitors conflicting with each other. Added a shared lock mechanism so only one monitor acts at a time.
- **False network blips**: Added debounce logic to ignore transient/false network state changes, preventing unnecessary proxy restarts.
- **Update checker**: Fixed `updateJson` pointing to the wrong (original) repo — module now correctly checks `tanvir-rayhan-akash/Proxy4KSU-TRA` for updates.
- **Update detection bug**: Removed invalid non-numeric suffix from `versionCode` in `module.prop` that caused the Update button to always show even when already up to date.

### Changed
- Slightly increased buffer size in the base Xray config for improved stability under load.
- Rebranded as **TRA Edition** (maintained by Tanvir Rayhan Akash), forked from the original Proxy4KSU project.

---

## v3.4.7 and earlier

See the upstream [Proxy4KSU](https://github.com/nhAsif/Proxy4KSU) project for changelog history prior to the TRA fork.
