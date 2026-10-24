[[ $- != *i* ]] && return

# -- Homebrew --
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# -- 起動時の表示 --
terminal_greeting="Hello"
terminal_greeting_file="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/terminal-greeting"
if [[ -r "$terminal_greeting_file" ]]; then
  IFS= read -r terminal_greeting < "$terminal_greeting_file" || terminal_greeting="Hello"
  [[ -n "$terminal_greeting" ]] || terminal_greeting="Hello"
fi
figlet -c -- "$terminal_greeting"
unset terminal_greeting terminal_greeting_file

# -- パス設定 --
export PATH="/Library/TeX/texbin:$HOME/.local/bin:$HOME/go/bin:$PATH"

# -- エディタの設定 --
export EDITOR='nvim'
export VISUAL='nvim'

# -- エイリアス設定 --
alias vim="nvim"
alias vi="nvim"

# -- プロンプト設定 --
if [ -f ~/.zsh_prompt ]; then
  source ~/.zsh_prompt
fi

# -- プラグイン設定の読み込み --
if [ -f ~/.zsh_plugins ]; then
  source ~/.zsh_plugins
fi

# the fuck 設定
eval "$(thefuck --alias)"
