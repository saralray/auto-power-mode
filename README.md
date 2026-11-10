# auto-power-mode

Automatically switch Linux `power-profiles-daemon` power modes when plugging in or unplugging the AC charger:
- **Charging (AC plugged in)** → `performance`
- **On Battery (AC unplugged)** → `power-saver`

It tracks the last AC state in `/var/lib/ac-power-profile/last-state` so manual overrides (e.g., manually switching to `power-saver` while plugged in) are respected until the next physical plug/unplug transition.

## Components

- `ac-power-profile.sh` → Installed to `/usr/local/bin/ac-power-profile.sh`
- `ac-power-profile.service` → Installed to `/etc/systemd/system/ac-power-profile.service`
- `99-ac-power-profile.rules` → Installed to `/etc/udev/rules.d/99-ac-power-profile.rules`

## Installation

```bash
git clone https://github.com/saralray/auto-power-mode.git
cd auto-power-mode
chmod +x install.sh
./install.sh
```

## Uninstallation

```bash
./install.sh --uninstall
```
