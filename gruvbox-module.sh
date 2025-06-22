# Network speed module for tmux-gruvbox
# Requires https://github.com/zeybek/tmux-net-speed
# 
# Installation:
# 1. Copy this file to ~/.tmux/plugins/tmux-gruvbox/status/network_speed.sh
# 2. Add 'network_speed' to your @gruvbox_status_modules_right in .tmux.conf
# 
# Customization options in .tmux.conf:
# set -g @gruvbox_network_speed_icon "🌐"
# set -g @gruvbox_network_speed_color "$thm_green"
# set -g @gruvbox_network_speed_text "#{net_speed}"

show_network_speed() {
  local index=$1
  local icon="$(get_tmux_option "@gruvbox_network_speed_icon" "󰖩")"
  local color="$(get_tmux_option "@gruvbox_network_speed_color" "$thm_blue")"
  local text="$(get_tmux_option "@gruvbox_network_speed_text" "#{net_speed}")"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
