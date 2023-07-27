# author: Amin Farjadi (github.com/amin-farjadi) (linkedin.com/in/aminfarjadi)
# date: 2021-10-25
# vim:ft=zsh ts=2 sw=2 sts=2

TRUE_COLOR="blue"
FALSE_COLOR="red"

current_time() {
    echo "%(?:⌚️ %{$fg_bold[$TRUE_COLOR]%}%*%{$reset_color%}:⌚️ %{$fg_bold[$FALSE_COLOR]%}%*%{$reset_color%})"
}

logo() {
    echo "%(?:%{$fg_bold[$TRUE_COLOR]%} %{$reset_color%}:%{$fg_bold[$FALSE_COLOR]%} %{$reset_color%})"
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


PROMPT='
$(logo)$(directory)$(git_prompt_info) %B%F{yellow}➜%f%b '
#❯%
RPROMPT='$(current_time)'

