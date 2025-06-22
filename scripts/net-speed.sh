#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

# Cache files
CACHE_DIR="/tmp/tmux-net-speed"
PREV_FILE="$CACHE_DIR/prev_stats"
DISPLAY_FILE="$CACHE_DIR/display"

# Create cache directory
mkdir -p "$CACHE_DIR"

# Calculate network speed
calculate_speed() {
  # Check dependencies first
  if ! check_dependencies >/dev/null 2>&1; then
    local separator=$(get_speed_separator)
    echo "↓ N/A $separator ↑ N/A"
    return
  fi
  
  local interface=$(get_primary_interface)
  local current_time=$(date +%s)
  
  # Validate interface
  if [ -z "$interface" ] || [ "$interface" = "unknown" ]; then
    local separator=$(get_speed_separator)
    echo "↓ N/A $separator ↑ N/A"
    return
  fi
  
  # Get current values
  local current_stats=$(get_network_stats "$interface")
  local current_rx=$(echo $current_stats | awk '{print $1}')
  local current_tx=$(echo $current_stats | awk '{print $2}')
  
  # Exit if values are empty or invalid
  if [ -z "$current_rx" ] || [ -z "$current_tx" ] || ! [[ "$current_rx" =~ ^[0-9]+$ ]] || ! [[ "$current_tx" =~ ^[0-9]+$ ]]; then
    local separator=$(get_speed_separator)
    echo "↓ 0B/s $separator ↑ 0B/s"
    return
  fi
  
  # Read previous values
  if [ -f "$PREV_FILE" ]; then
    local prev_data=$(cat "$PREV_FILE")
    local prev_time=$(echo $prev_data | awk '{print $1}')
    local prev_rx=$(echo $prev_data | awk '{print $2}')
    local prev_tx=$(echo $prev_data | awk '{print $3}')
    
    # Calculate time difference
    local time_diff=$((current_time - prev_time))
    
    if [ $time_diff -ge 2 ]; then
      # Calculate speed
      local rx_diff=$((current_rx - prev_rx))
      local tx_diff=$((current_tx - prev_tx))
      
      # Reset negative values to zero
      if [ $rx_diff -lt 0 ]; then rx_diff=0; fi
      if [ $tx_diff -lt 0 ]; then tx_diff=0; fi
      
      local download_speed=$((rx_diff / time_diff))
      local upload_speed=$((tx_diff / time_diff))
      
      # Format the values
      local download_formatted=$(format_bytes $download_speed)
      local upload_formatted=$(format_bytes $upload_speed)
      local separator=$(get_speed_separator)
      
      # Save and display result
      echo "↓ $download_formatted $separator ↑ $upload_formatted" > "$DISPLAY_FILE"
      echo "$current_time $current_rx $current_tx" > "$PREV_FILE"
      echo "↓ $download_formatted $separator ↑ $upload_formatted"
      return
    fi
  else
    # First run
    echo "$current_time $current_rx $current_tx" > "$PREV_FILE"
  fi
  
  # Show previous result or default
  if [ -f "$DISPLAY_FILE" ]; then
    cat "$DISPLAY_FILE"
  else
    local separator=$(get_speed_separator)
    echo "↓ 0B/s $separator ↑ 0B/s"
  fi
}

main() {
  calculate_speed
}

main
