#!/usr/bin/env bash

PATH="/usr/local/bin:$PATH:/usr/sbin"

# Detect operating system
detect_os() {
  case "$(uname -s)" in
    Darwin*)    echo "macos" ;;
    Linux*)     echo "linux" ;;
    *)          echo "unknown" ;;
  esac
}

# Check system dependencies
check_dependencies() {
  local os=$(detect_os)
  local missing_deps=""
  
  case $os in
    "macos")
      command -v route >/dev/null 2>&1 || missing_deps="$missing_deps route"
      command -v netstat >/dev/null 2>&1 || missing_deps="$missing_deps netstat"
      ;;
    "linux")
      if ! command -v ip >/dev/null 2>&1 && ! command -v route >/dev/null 2>&1; then
        missing_deps="$missing_deps ip-or-route"
      fi
      if [ ! -f "/proc/net/dev" ] && ! command -v netstat >/dev/null 2>&1; then
        missing_deps="$missing_deps proc-net-dev-or-netstat"
      fi
      ;;
  esac
  
  command -v bc >/dev/null 2>&1 || missing_deps="$missing_deps bc"
  
  if [ -n "$missing_deps" ]; then
    echo "Missing dependencies:$missing_deps" >&2
    return 1
  fi
  return 0
}

get_tmux_option() {
  local option_name="$1"
  local default_value="$2"
  local option_value=$(tmux show-option -gqv $option_name)

  if [ -z "$option_value" ]; then
    echo -n $default_value
  else
    echo -n $option_value
  fi
}

set_tmux_option() {
  local option_name="$1"
  local option_value="$2"
  $(tmux set-option -gq $option_name "$option_value")
}

# Convert bytes to readable format
format_bytes() {
  local bytes=$1
  local unit=""
  
  if [ $bytes -ge 1073741824 ]; then
    # GB
    unit=$(echo "scale=1; $bytes / 1073741824" | bc)
    echo "${unit}GB/s"
  elif [ $bytes -ge 1048576 ]; then
    # MB
    unit=$(echo "scale=1; $bytes / 1048576" | bc)
    echo "${unit}MB/s"
  elif [ $bytes -ge 1024 ]; then
    # KB
    unit=$(echo "scale=1; $bytes / 1024" | bc)
    echo "${unit}KB/s"
  else
    # Bytes
    echo "${bytes}B/s"
  fi
}

# Find primary network interface (cross-platform)
get_primary_interface() {
  local os=$(detect_os)
  
  case $os in
    "macos")
      route get default 2>/dev/null | grep interface | awk '{print $2}' || echo "en0"
      ;;
    "linux")
      # Try 3 different methods for Linux
      ip route show default 2>/dev/null | awk '/default/ { print $5 }' | head -1 || \
      route -n 2>/dev/null | awk '$1 == "0.0.0.0" {print $8}' | head -1 || \
      echo "eth0"
      ;;
    *)
      echo "eth0"  # Default fallback
      ;;
  esac
}

# Get network statistics (cross-platform)
get_network_stats() {
  local interface=$1
  local os=$(detect_os)
  
  case $os in
    "macos")
      # macOS: use netstat
      netstat -ibn | grep "^$interface " | head -1 | awk '{print $7 " " $10}'
      ;;
    "linux")
      # Linux: use /proc/net/dev
      if [ -f "/proc/net/dev" ]; then
        grep "$interface:" /proc/net/dev | awk -F: '{print $2}' | awk '{print $1 " " $9}'
      else
        # Fallback: netstat (different format)
        netstat -i | grep "^$interface " | awk '{print $4 " " $8}'
      fi
      ;;
    *)
      echo "0 0"
      ;;
  esac
}

# Get network speed separator (customizable)
get_speed_separator() {
  # Check if option exists
  if tmux show-option -gq "@tmux_net_speed_separator" >/dev/null 2>&1; then
    local separator="$(tmux show-option -gqv "@tmux_net_speed_separator")"
    echo "$separator"
  else
    echo "•"
  fi
}
test_platform_compatibility() {
  echo "OS: $(detect_os)"
  echo "Dependencies: $(check_dependencies && echo "OK" || echo "MISSING")"
  echo "Primary Interface: $(get_primary_interface)"
  echo "Network Stats: $(get_network_stats $(get_primary_interface))"
}
