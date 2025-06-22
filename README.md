# tmux-net-speed

Real-time network speed monitoring plugin for tmux status bar.

![Demo](https://img.shields.io/badge/demo-↓%20125.3KB/s%20•%20↑%2015.7KB/s-brightgreen)

## ✨ Features

- 🚀 **Real-time monitoring** - Shows live download/upload speeds
- 🎨 **Beautiful display** - Clean format with arrows and separators
- 🔧 **Auto-detection** - Automatically finds your primary network interface
- 📊 **Smart units** - Auto-converts between B/s, KB/s, MB/s, GB/s
- 🎯 **Lightweight** - Minimal resource usage with file-based caching
- 🌈 **Theme compatible** - Works with Gruvbox and other tmux themes

## 📸 Preview

```
Status bar: [session] [user] [date] [battery] [weather] [󰖩 ↓ 125.3KB/s • ↑ 15.7KB/s]
```

## 🚀 Installation

### Prerequisites

#### macOS

- `route` and `netstat` commands (usually pre-installed)
- `bc` command for floating point calculations
- tmux 2.1+

#### Linux

- `ip` command (from iproute2 package) OR `route` command (from net-tools)
- `/proc/net/dev` filesystem OR `netstat` command
- `bc` command for floating point calculations
- tmux 2.1+

#### Installation of dependencies:

```bash
# Ubuntu/Debian
sudo apt-get install iproute2 bc

# CentOS/RHEL/Fedora
sudo yum install iproute bc
# or (newer versions)
sudo dnf install iproute bc

# Arch Linux
sudo pacman -S iproute2 bc

# macOS (if bc is missing)
brew install bc
```

### Method 1: Manual Installation

1. Clone this repository:

```bash
git clone https://github.com/zeybek/tmux-net-speed.git ~/.tmux/plugins/tmux-net-speed
```

2. Add to your `.tmux.conf`:

```bash
# Load the plugin
run-shell ~/.tmux/plugins/tmux-net-speed/tmux-net-speed.tmux

# Add to status bar (basic usage)
set -g status-right "#{net_speed} | %H:%M"
```

3. Reload tmux configuration:

```bash
tmux source-file ~/.tmux.conf
```

### Method 2: With Gruvbox Theme

If you're using [tmux-gruvbox](https://github.com/z3z1ma/tmux-gruvbox) theme:

1. Install the plugin as above

2. Copy the Gruvbox module:

```bash
cp ~/.tmux/plugins/tmux-net-speed/gruvbox-module.sh ~/.tmux/plugins/tmux-gruvbox/status/network_speed.sh
```

3. Add to your Gruvbox modules in `.tmux.conf`:

```bash
set -g @gruvbox_status_modules_right "session user date_time battery weather network_speed"
```

4. (Optional) Customize the appearance:
```bash
set -g @gruvbox_network_speed_icon "🌐"
set -g @gruvbox_network_speed_color "$thm_green"
set -g @gruvbox_network_speed_text "#{net_speed}"
```

### Method 3: With TPM (Tmux Plugin Manager)

Add to `.tmux.conf`:

```bash
set -g @plugin 'zeybek/tmux-net-speed'
```

Press `prefix + I` to install.

## ⚙️ Configuration

### Basic Usage

```bash
# Simple usage
set -g status-right "#{net_speed}"

# With other elements
set -g status-right "#{net_speed} | #{battery_percentage} | %H:%M"

# Custom format
set -g status-right "#(/path/to/tmux-net-speed/scripts/net-speed.sh)"
```

### Advanced Options

```bash
# Update interval (default: 2 seconds)
set -g @tmux-net-speed-interval 1

# Specific network interface (default: auto-detect)
set -g @tmux-net-speed-interface "en1"

# Custom separator between download and upload (default: "•")
set -g @tmux_net_speed_separator "|"

# Gruvbox theme customization
set -g @gruvbox_network_speed_icon "🌐"
set -g @gruvbox_network_speed_color "$thm_green"
set -g @gruvbox_network_speed_text "#{net_speed}"
```

## 🎨 Output Format

The plugin displays network speeds in this format:

```
↓ [download_speed] [separator] ↑ [upload_speed]
```

**Default format (with • separator):**

- `↓ 0B/s • ↑ 0B/s` (no activity)
- `↓ 1.2KB/s • ↑ 256B/s` (light usage)
- `↓ 15.7MB/s • ↑ 2.3MB/s` (heavy usage)
- `↓ 1.1GB/s • ↑ 850MB/s` (very heavy usage)

**Custom separator examples:**
```bash
# Pipe separator
set -g @tmux_net_speed_separator "|"
# Result: ↓ 15.7MB/s | ↑ 2.3MB/s

# Dash separator  
set -g @tmux_net_speed_separator "-"
# Result: ↓ 15.7MB/s - ↑ 2.3MB/s

# Arrow separator
set -g @tmux_net_speed_separator "→"
# Result: ↓ 15.7MB/s → ↑ 2.3MB/s

# No separator (space only)
set -g @tmux_net_speed_separator ""
# Result: ↓ 15.7MB/s ↑ 2.3MB/s
```

## 🔧 How It Works

1. **OS Detection**: Automatically detects your operating system (macOS/Linux)
2. **Interface Detection**: Finds your primary network interface using platform-specific commands:
   - macOS: `route get default`
   - Linux: `ip route show default` or `route -n`
3. **Data Collection**: Gathers interface statistics using:
   - macOS: `netstat -ibn`
   - Linux: `/proc/net/dev` or `netstat -i`
4. **Speed Calculation**: Calculates bytes/second based on time intervals
5. **Caching**: Uses file-based caching in `/tmp/tmux-net-speed/` for efficiency
6. **Display**: Formats and displays the speeds with appropriate units

## 🌍 Platform Compatibility

| Feature             | macOS | Linux | Status         |
| ------------------- | ----- | ----- | -------------- |
| Interface Detection | ✅    | ✅    | Cross-platform |
| Network Statistics  | ✅    | ✅    | Cross-platform |
| Byte Formatting     | ✅    | ✅    | Cross-platform |
| Cache System        | ✅    | ✅    | Cross-platform |
| Tmux Integration    | ✅    | ✅    | Cross-platform |

### Tested Distributions:

- **macOS**: 10.15+ (Catalina and newer)
- **Linux**: Ubuntu 18.04+, Debian 10+, CentOS 7+, Fedora 30+, Arch Linux

## 📁 File Structure

```
tmux-net-speed/
├── tmux-net-speed.tmux          # Main plugin file
├── README.md                    # This file
├── LICENSE                      # MIT License
├── gruvbox-module.sh           # Gruvbox theme integration
└── scripts/
    ├── helpers.sh              # Helper functions
    └── net-speed.sh           # Main speed calculation script
```

## 🐛 Troubleshooting

### Plugin not showing

1. Check if the plugin is loaded: `tmux show-option -g status-right`
2. Test the script manually: `~/.tmux/plugins/tmux-net-speed/scripts/net-speed.sh`
3. Reload tmux config: `tmux source-file ~/.tmux.conf`

### Shows N/A constantly

This indicates missing system dependencies:

1. **Check dependencies**: Run the test function in the plugin directory:
   ```bash
   cd ~/.tmux/plugins/tmux-net-speed/scripts
   source helpers.sh && test_platform_compatibility
   ```
2. **Install missing packages** (see Prerequisites section above)

### Shows 0B/s constantly

1. **Check your network interface**:
   - macOS: `route get default`
   - Linux: `ip route show default` or `route -n`
2. **Verify interface statistics**:
   - macOS: `netstat -ibn | grep YOUR_INTERFACE`
   - Linux: `cat /proc/net/dev | grep YOUR_INTERFACE`
3. **Wait a few seconds** for initial measurements

### Linux-specific issues

1. **Interface not found**: Some Linux distributions use different interface names (`enp0s3`, `ens33`, `wlan0`)
2. **Permission errors**: Ensure `/proc/net/dev` is readable
3. **Missing iproute2**: Install with `sudo apt-get install iproute2` (Ubuntu/Debian)

### Permission errors

```bash
chmod +x ~/.tmux/plugins/tmux-net-speed/tmux-net-speed.tmux
chmod +x ~/.tmux/plugins/tmux-net-speed/scripts/*.sh
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [tmux-weather](https://github.com/xamut/tmux-weather)
- Compatible with [tmux-gruvbox](https://github.com/z3z1ma/tmux-gruvbox) theme
- Built for the tmux community

## 📊 Stats

![GitHub stars](https://img.shields.io/github/stars/zeybek/tmux-net-speed)
![GitHub forks](https://img.shields.io/github/forks/zeybek/tmux-net-speed)
![GitHub issues](https://img.shields.io/github/issues/zeybek/tmux-net-speed)
![GitHub license](https://img.shields.io/github/license/zeybek/tmux-net-speed)

---

Made with ❤️ for the tmux community
