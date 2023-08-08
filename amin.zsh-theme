# author: Amin Farjadi (github.com/amin-farjadi) (linkedin.com/in/aminfarjadi)
# date: 2023-08-08
# vim:ft=zsh ts=2 sw=2 sts=2

TRUE_COLOR="blue"
FALSE_COLOR="red"

current_time() {
  echo "%(?:%{$fg_bold[$TRUE_COLOR]%}%*%{$reset_color%}:%{$fg_bold[$FALSE_COLOR]%}%*%{$reset_color%})"
}

apple_logo() {
  echo "%(?:%{$fg_bold[$TRUE_COLOR]%} %{$reset_color%}:%{$fg_bold[$FALSE_COLOR]%} %{$reset_color%})"
}

# requires Nerd Font - https://github.com/ryanoasis/nerd-fonts/
terminal_logo() {
  echo "%(?:%{$fg[$TRUE_COLOR]%} %{$reset_color%}:%{$fg[$FALSE_COLOR]%} %{$reset_color%})"
}

directory() {
  echo "%{$fg_bold[green]%}%~%{$reset_color%}"
}


# Must use Powerline font, for \uE0A0 to render.
ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[cyan]%}\uE0A0 "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# #region config for https://github.com/jeffreytse/zsh-vi-mode
function zvm_config() {
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
}

MODE_INDICATOR_VIINS='%F{8}INSERT%f'
MODE_INDICATOR_VICMD='%F{2}NORMAL%f'
MODE_INDICATOR_REPLACE='%F{1}REPLACE%f'
MODE_INDICATOR_SEARCH='%F{5}SEARCH%f'
MODE_INDICATOR_VISUAL='%F{12}%F{4}VISUAL%f'
MODE_INDICATOR_VLINE='%F{4}V-LINE%f'

function zvm_after_select_vi_mode() {

  MODE_INDICATOR=''

  case $ZVM_MODE in

    $ZVM_MODE_NORMAL)
      MODE_INDICATOR=$MODE_INDICATOR_VICMD
      ;;
    $ZVM_MODE_INSERT)
      MODE_INDICATOR=$MODE_INDICATOR_VIINS
      ;;
    $ZVM_MODE_VISUAL)
      MODE_INDICATOR=$MODE_INDICATOR_VISUAL
      ;;
    $ZVM_MODE_VISUAL_LINE)
      MODE_INDICATOR=$MODE_INDICATOR_VLINE
      ;;
    $ZVM_MODE_REPLACE)
      MODE_INDICATOR=$MODE_INDICATOR_REPLACE
      ;;

  esac

  RPROMPT="%F{40} %f${MODE_INDICATOR}"

  zle reset-prompt
  zle -R

}
# #endregion

# #region two-line-prompt
# Example of two-line ZSH prompt with four components.
#
#   top-left                         top-right
#   bottom-left                   bottom-right
#
# Components can be customized by editing set-prompt function.
#
# Installation:
#
#   (cd && curl -fsSLO https://gist.githubusercontent.com/romkatv/2a107ef9314f0d5f76563725b42f7cab/raw/two-line-prompt.zsh)
#   echo 'source ~/two-line-prompt.zsh' >>~/.zshrc
#
# Accompanying article:
# https://www.reddit.com/r/zsh/comments/cgbm24/multiline_prompt_the_missing_ingredient/
#
# This is only an example. If you are looking for a good ZSH prompt,
# try https://github.com/romkatv/powerlevel10k/.

# Usage: prompt-length TEXT [COLUMNS]
#
# If you run `print -P TEXT`, how many characters will be printed
# on the last line?
#
# Or, equivalently, if you set PROMPT=TEXT with prompt_subst
# option unset, on which column will the cursor be?
#
# The second argument specifies terminal width. Defaults to the
# real terminal width.
#
# The result is stored in REPLY.
#
# Assumes that `%{%}` and `%G` don't lie.
#
# Examples:
#
#   prompt-length ''            => 0
#   prompt-length 'abc'         => 3
#   prompt-length $'abc\nxy'    => 2
#   prompt-length '❎'          => 2
#   prompt-length $'\t'         => 8
#   prompt-length $'\u274E'     => 2
#   prompt-length '%F{red}abc'  => 3
#   prompt-length $'%{a\b%Gb%}' => 1
#   prompt-length '%D'          => 8
#   prompt-length '%1(l..ab)'   => 2
#   prompt-length '%(!.a.)'     => 1 if root, 0 if not
function prompt-length() {
  emulate -L zsh
  local -i COLUMNS=${2:-COLUMNS}
  local -i x y=${#1} m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ))
    done
    while (( y > x + 1 )); do
      (( m = x + (y - x) / 2 ))
      (( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
    done
  fi
  typeset -g REPLY=$x
}

# Usage: fill-line LEFT RIGHT
#
# Sets REPLY to LEFT<spaces>RIGHT with enough spaces in
# the middle to fill a terminal line.
function fill-line() {
  emulate -L zsh
  prompt-length $1
  local -i left_len=REPLY
  prompt-length $2 9999
  local -i right_len=REPLY
  local -i pad_len=$((COLUMNS - left_len - right_len - ${ZLE_RPROMPT_INDENT:-1}))
  if (( pad_len < 1 )); then
    # Not enough space for the right part. Drop it.
    typeset -g REPLY=$1
  else
    local pad=${(pl.$pad_len.. .)}  # pad_len spaces
    typeset -g REPLY=${1}${pad}${2}
  fi
}

# Sets PROMPT and RPROMPT.
#
# Requires: prompt_percent and no_prompt_subst.
function set-prompt() {
  emulate -L zsh
  local git_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  git_branch=${git_branch//\%/%%}  # escape '%'

  # ~/foo/bar                     master
  # % █                            10:51
  #
  # Top left:      Blue current directory.
  # Top right:     Green Git branch.
  # Bottom left:   '#' if root, '%' if not; green on success, red on error.
  # Bottom right:  Yellow current time.

  local top_left="$(terminal_logo)$(directory)$(git_prompt_info)"
  local top_right="$(current_time)"
  local bottom_left='%B%F{yellow}→%f%b '
  local bottom_right=''

  local REPLY
  fill-line "$top_left" "$top_right"
  PROMPT=$REPLY$'\n'$bottom_left
  # RPROMPT=$bottom_right
}

setopt no_prompt_{bang,subst} prompt_{cr,percent,sp}
autoload -Uz add-zsh-hook
add-zsh-hook precmd set-prompt
# #endregion

RPROMPT=''
