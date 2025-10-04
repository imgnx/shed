# shed
> Shed load. Shed weight. Shed light.

**shed** is a tiny cross-platform CLI that gives you human-friendly control over process priority:
- macOS: wraps `taskpolicy` (+ `renice`)
- Linux: wraps `systemd-run --user --scope` (+ `nice`/`ionice` fallback)

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)
![No Telemetry](https://img.shields.io/badge/telemetry-none-blue)
![No CLA](https://img.shields.io/badge/CLA-not_required-informational)

## Install
```sh
# quick local install
git clone https://github.com/YOURUSER/shed.git
cd shed
chmod +x bin/shed
sudo ln -sf "$PWD/bin/shed" /usr/local/bin/shed
# (optional) Zsh helper
echo "source $PWD/contrib/zsh/focus-burst.zsh" >> ~/.zshrc
```

## Usage
```sh
shed bg pm2             # deprioritize all matching processes
shed bg cloudflared
shed focus npm install  # run command at interactive priority
shed work long-task     # normal tier
shed bump 12345         # temporarily boost a PID
```

### Behavior
- **Patterns**: a single word (e.g. `pm2`) treats it as a process pattern (pgrep -f).
- **Commands**: otherwise, runs the provided command under the mode.
- **Linux systemd**: if available, uses a transient scope with CPU/IO weights.
- **Fallbacks**: Linux w/o systemd → `nice`/`ionice`. macOS → QoS via `taskpolicy`.

## UNRESTRICTIONS

This project imposes **no extra restrictions** beyond the MIT License. In plain English:

- ✅ You may **use, copy, modify, merge, publish, distribute, and sell** this software (including as part of a commercial/closed-source product or hosted service).
- ✅ You may **fork** it, **vendor** it, **bundle** it, and **rename** your fork.
- ✅ You may **automate** it, **script** it, and **embed** it in other tools.
- ✅ No CLA, no registration, no telemetry, no “phone-home,” no forced updates.
- ✅ No “open-core” feature gating. The repo contains everything you need.

The only obligations are the standard MIT ones:
- 📎 **Keep the license and copyright notice** in source or “substantial portions.”
- ⚠️ **No warranty**: see the MIT text for the “as is” disclaimer.

**Notes**
- Using the name “shed” to refer to this project is fine; no logo/trademark program here. If you publish a derivative under a new name, just don’t imply endorsement.
- If your company needs a one-liner for legal: “No additional restrictions beyond MIT. No telemetry.” 
- If you’re packaging for distros or app stores, include `LICENSE` in your package.

## Why?
Developers often need to:
- push daemons into the background tier,
- keep editors/REPLs snappy,
- temporarily boost a single heavy command.
Existing tools exist but aren’t unified or ergonomic. **shed** glues them together.

## License
MIT — see [LICENSE](LICENSE).
