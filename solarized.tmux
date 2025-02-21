#!/usr/bin/env bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POWERLINE_ICONS_STATUS_LINE_FILE=powerline-icons-status-line.conf

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

set() {
  local option=$1
  local value=$2
  tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
  local option=$1
  local value=$2
  tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

main() {
  local theme
  theme="$(get_tmux_option "@solarized_flavour" "solarized")"

  # Aggregate all commands in one array
  local tmux_commands=()

  # NOTE: Pulling in the selected theme by the theme that's being set as local
  # variables.
  source /dev/stdin <<<"$(sed -e "/^[^#].*=/s/^/local /" "${PLUGIN_DIR}/solarized-${theme}.tmuxtheme")"

  # status
  set status "on"
  set status-bg "${thm_bg}"
  set status-justify "left"
  set status-left-length "100"
  set status-right-length "100"

  # messages
  set message-style "fg=${thm_cyan},bg=${thm_gray},align=centre"
  set message-command-style "fg=${thm_cyan},bg=${thm_gray},align=centre"

  # panes
  set pane-border-style "fg=${thm_gray}"
  set pane-active-border-style "fg=${thm_blue}"

  # windows
  setw window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
  setw window-status-separator ""
  setw window-status-style "fg=${thm_fg},bg=${thm_bg},none"

  # --------=== Statusline

  # NOTE: Checking for the value of @solarized_window_tabs_enabled
  local wt_enabled
  wt_enabled="$(get_tmux_option "@solarized_window_tabs_enabled" "off")"
  readonly wt_enabled

  local powerline_theme_enabled
  powerline_theme_enabled="$(get_tmux_option "@solarized_powerline_theme_enabled" "off")"
  readonly powerline_theme_enabled

  local powerline_icons_theme_enabled
  powerline_icons_theme_enabled="$(get_tmux_option "@solarized_powerline_icons_theme_enabled" "off")"
  readonly powerline_icons_theme_enabled

  # Separators for the left status / window list
  local l_left_separator
  l_left_separator="$(get_tmux_option "@solarized_l_left_separator" "")"
  readonly l_left_separator

  local l_right_separator
  l_right_separator="$(get_tmux_option "@solarized_l_right_separator" "")"
  readonly l_right_separator

  # Separators for the right status
  local r_left_separator
  r_left_separator="$(get_tmux_option "@solarized_r_left_separator" "")"
  readonly r_left_separator

  local r_right_separator
  r_right_separator="$(get_tmux_option "@solarized_r_right_separator" "")"
  readonly r_right_separator

  local user
  user="$(get_tmux_option "@solarized_user" "off")"
  readonly user

  local host
  host="$(get_tmux_option "@solarized_host" "off")"
  readonly host

  local date_time
  date_time="$(get_tmux_option "@solarized_date_time" "off")"
  readonly date_time

  # Icons
  local directory_icon
  directory_icon="$(get_tmux_option "@solarized_directory_icon" "")"
  readonly directory_icon

  local window_icon
  window_icon="$(get_tmux_option "@solarized_window_icon" "")"
  readonly window_icon

  local session_icon
  session_icon="$(get_tmux_option "@solarized_session_icon" "")"
  readonly session_icon

  local user_icon
  user_icon="$(get_tmux_option "@solarized_user_icon" "")"
  readonly user_icon

  local host_icon
  host_icon="$(get_tmux_option "@solarized_host_icon" "󰒋")"
  readonly host_icon

  local datetime_icon
  datetime_icon="$(get_tmux_option "@solarized_datetime_icon" "")"
  readonly datetime_icon

  # Source status line themes
  source "$PLUGIN_DIR/$POWERLINE_ICONS_STATUS_LINE_FILE"

  # Right column 1 by default shows the Window name.
  local right_column1=$show_window

  # Right column 2 by default shows the current Session name.
  local right_column2=$show_session

  # Window status by default shows the current directory basename.
  local window_status_format=$show_directory_in_window_status
  local window_status_current_format=$show_directory_in_window_status_current

  # NOTE: With the @solarized_window_tabs_enabled set to on, we're going to
  # update the right_column1 and the window_status_* variables.
  if [[ "${wt_enabled}" == "on" ]]; then
    right_column1=$show_directory
    window_status_format=$show_window_in_window_status
    window_status_current_format=$show_window_in_window_status_current
  fi

  if [[ "${user}" == "on" ]]; then
    right_column2="$right_column2$show_user"
  fi

  if [[ "${host}" == "on" ]]; then
    right_column2="$right_column2$show_host"
  fi

  if [[ "${date_time}" != "off" ]]; then
    right_column2="$right_column2$show_date_time"
  fi

  set status-left ""
  set status-right "${right_column1}${right_column2}"

  setw window-status-format "${window_status_format}"
  setw window-status-current-format "${window_status_current_format}"

  # --------=== Modes
  #
  setw clock-mode-colour "${thm_blue}"
  setw mode-style "fg=${thm_pink} bg=${thm_black4} bold"

  tmux "${tmux_commands[@]}"
}

main "$@"
