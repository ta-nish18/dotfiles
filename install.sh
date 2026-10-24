#!/bin/bash
set -eu

# dotfilesディレクトリに移動
cd "$(dirname "$0")"

os_name=$(uname -s)

# ターミナル起動時のメッセージは端末ごとのローカル設定として保存する。
greeting_dir="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
greeting_file="$greeting_dir/terminal-greeting"
greeting="Hello"

if [ -r "$greeting_file" ]; then
  IFS= read -r saved_greeting < "$greeting_file" || true
  if [ -n "${saved_greeting:-}" ]; then
    greeting=$saved_greeting
  fi
fi

if [ -t 0 ]; then
  printf 'Terminal greeting [%s]: ' "$greeting"
  IFS= read -r entered_greeting || entered_greeting=""
  if [ -n "$entered_greeting" ]; then
    greeting=$entered_greeting
  fi
else
  echo "Non-interactive setup: using terminal greeting '$greeting'."
fi

mkdir -p "$greeting_dir"
printf '%s\n' "$greeting" > "$greeting_file"
chmod 600 "$greeting_file"

# macOSではAnsibleの有無にかかわらず、先にHomebrewを準備する。
if [ "$os_name" = "Darwin" ]; then
  brew_bin=""
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$candidate" ]; then
      brew_bin=$candidate
      break
    fi
  done

  if [ -z "$brew_bin" ] && command -v brew >/dev/null 2>&1; then
    brew_bin=$(command -v brew)
  fi

  if [ -z "$brew_bin" ]; then
    echo "Homebrew not found. Installing from the official Homebrew installer..."
    /bin/bash -c "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      if [ -x "$candidate" ]; then
        brew_bin=$candidate
        break
      fi
    done
  fi

  if [ -z "$brew_bin" ] || [ ! -x "$brew_bin" ]; then
    echo "Homebrew installation did not produce a usable brew command." >&2
    exit 1
  fi

  eval "$("$brew_bin" shellenv)"

  if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "Ansible not found. Installing with Homebrew..."
    HOMEBREW_NO_AUTO_UPDATE=1 "$brew_bin" install ansible
  else
    echo "Ansible is already installed."
  fi

# それ以外
else
  if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "Unsupported OS. Please install Ansible manually."
    exit 1
  else
    echo "Ansible is already installed."
  fi
fi

# 必要なコレクションのインストール
echo "Installing Ansible Galaxy collections..."
ansible-galaxy collection install community.general

# Playbook の実行
echo "Running Ansible Playbook..."
ansible-playbook ansible/local.yml

echo "Done!"
