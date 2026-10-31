#!/bin/bash
# Tailscale経由のSSH接続をセットアップする。
#   クライアント側: 鍵の作成 → 接続先の選択 → 公開鍵のコピー → ~/.ssh/config への追記
#   ホスト側      : SSHサーバー（リモートログイン）の有効化
# 対応OS: macOS / Linux
set -eu

os_name=$(uname -s)

# ---------- 共通の補助関数 ----------
info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m警告:\033[0m %s\n' "$*" >&2; }
die()   { printf '\033[1;31mエラー:\033[0m %s\n' "$*" >&2; exit 1; }

# ask "質問" "既定値" → 入力値（空なら既定値）を echo
ask() {
  local prompt=$1 default=${2:-} answer
  if [ -n "$default" ]; then
    read -r -p "$prompt [$default]: " answer
  else
    read -r -p "$prompt: " answer
  fi
  printf '%s' "${answer:-$default}"
}

# confirm "質問" → y なら 0
confirm() {
  local answer
  read -r -p "$1 [y/N]: " answer
  case $answer in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
}

# tailscale コマンドを探す（PATHになければmacOSアプリ同梱のCLI）
find_tailscale() {
  if command -v tailscale >/dev/null 2>&1; then
    command -v tailscale
  elif [ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]; then
    echo /Applications/Tailscale.app/Contents/MacOS/Tailscale
  else
    return 1
  fi
}

[ -t 0 ] || die "対話的に実行してください。"

# ---------- クライアント側 ----------
setup_client() {
  local ssh_dir="$HOME/.ssh" ts
  ts=$(find_tailscale) || die "tailscale コマンドが見つかりません。先に install.sh を実行するか、Tailscale をインストールしてください。"

  mkdir -p "$ssh_dir"
  chmod 700 "$ssh_dir"

  # 1. 鍵の作成
  info "SSHキーを準備します"
  local key_name key_path
  while :; do
    key_name=$(ask "鍵のファイル名（~/.ssh/ 以下）" "id_ed25519")
    case $key_name in
      */*|"") warn "ファイル名だけを入力してください（/ は使えません）。"; continue ;;
    esac
    key_path="$ssh_dir/$key_name"
    if [ -e "$key_path" ]; then
      if confirm "$key_path は既にあります。この鍵をそのまま使いますか？"; then
        break
      fi
      continue
    fi
    # パスフレーズは ssh-keygen 自身に質問させる（コマンドライン引数に残さないため）
    echo "続けてパスフレーズを聞かれます。空のままEnterでパスフレーズなしになります。"
    ssh-keygen -t ed25519 -f "$key_path" -C "$(whoami)@$(hostname -s)"
    break
  done
  [ -f "$key_path.pub" ] || die "公開鍵 $key_path.pub が見つかりません。"

  # 2. 接続先の選択
  info "Tailscale のデバイス一覧を取得します"
  local self_ip status_lines
  self_ip=$("$ts" ip -4 2>/dev/null | head -n1 || true)
  status_lines=$("$ts" status 2>/dev/null | awk -v self="$self_ip" '$1 ~ /^100\./ && $1 != self {print $1, $2, $4, $5}') \
    || die "tailscale status に失敗しました。Tailscale にログインしているか確認してください。"
  [ -n "$status_lines" ] || die "接続できる他のデバイスが見つかりません。"

  local -a ips names
  local i=0 ip name os state
  printf '\n  %-3s %-16s %-24s %-8s %s\n' "No" "IP" "マシン名" "OS" "状態"
  while read -r ip name os state; do
    i=$((i + 1))
    ips[i]=$ip
    names[i]=$name
    printf '  %-3s %-16s %-24s %-8s %s\n' "$i" "$ip" "$name" "$os" "${state:-}"
  done <<< "$status_lines"
  echo

  local choice
  while :; do
    choice=$(ask "接続先の番号")
    if [[ $choice =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$i" ]; then
      break
    fi
    warn "1〜$i の番号を入力してください。"
  done
  local target_ip=${ips[choice]} target_name=${names[choice]}
  info "選択: $target_name ($target_ip)"

  # 3. ユーザー名
  local remote_user
  remote_user=$(ask "接続先のユーザー名（接続先で whoami を実行すると分かります）" "$(whoami)")

  # 4. 公開鍵のコピー
  info "公開鍵を $remote_user@$target_ip にコピーします（接続先のログインパスワードを聞かれます）"
  if command -v ssh-copy-id >/dev/null 2>&1; then
    ssh-copy-id -i "$key_path.pub" "$remote_user@$target_ip"
  else
    ssh "$remote_user@$target_ip" 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys' < "$key_path.pub"
  fi

  # 5. ~/.ssh/config への追記
  local config="$ssh_dir/config" host_alias
  touch "$config"
  chmod 600 "$config"
  while :; do
    host_alias=$(ask "ssh [id] で使う id" "$target_name")
    if [[ ! $host_alias =~ ^[A-Za-z0-9._-]+$ ]]; then
      warn "英数字と . _ - だけで入力してください。"
      continue
    fi
    if grep -qiE "^[[:space:]]*Host[[:space:]]+(.*[[:space:]])?${host_alias//./\\.}([[:space:]]|$)" "$config"; then
      warn "Host $host_alias は既に $config にあります。別の名前にするか、手で編集してください。"
      continue
    fi
    break
  done

  cp "$config" "$config.bak.$(date +%Y%m%d%H%M%S)"
  {
    [ -s "$config" ] && echo
    echo "# mkssh.sh で追加 ($(date '+%Y-%m-%d'))"
    echo "Host $host_alias"
    echo "    HostName $target_ip"
    echo "    User $remote_user"
    echo "    IdentityFile ~/.ssh/$key_name"
    echo "    IdentitiesOnly yes"
    echo "    ServerAliveInterval 60"
    echo "    AddKeysToAgent yes"
    if [ "$os_name" = "Darwin" ]; then
      echo "    UseKeychain yes"
    fi
  } >> "$config"
  info "$config に Host $host_alias を追加しました（元のファイルは .bak に退避）"

  # パスフレーズ付きの鍵なら、macOSではキーチェーンに登録して入力を省く
  if [ "$os_name" = "Darwin" ] && ! ssh-keygen -y -P "" -f "$key_path" >/dev/null 2>&1; then
    if confirm "パスフレーズをキーチェーンに保存して、次回から入力を省きますか？"; then
      ssh-add --apple-use-keychain "$key_path"
    fi
  fi

  # 6. 接続テスト
  info "接続テスト: ssh $host_alias"
  if ssh -o ConnectTimeout=10 "$host_alias" 'echo "OK: $(whoami)@$(hostname)"'; then
    echo
    info "完了しました。今後は次のコマンドで接続できます:"
    echo "    ssh $host_alias"
  else
    warn "接続テストに失敗しました。接続先で mkssh.sh のホスト側設定が済んでいるか確認してください。"
  fi
}

# ---------- ホスト側 ----------
setup_host() {
  info "このPCへのSSH接続（リモートログイン）を有効にします"

  if [ "$os_name" = "Darwin" ]; then
    if sudo systemsetup -getremotelogin 2>/dev/null | grep -qi ': on'; then
      info "リモートログインは既に有効です。"
    elif sudo systemsetup -setremotelogin on 2>/dev/null; then
      info "リモートログインを有効にしました。"
    else
      # 新しいmacOSではターミナルにフルディスクアクセスがないと systemsetup が失敗する
      warn "コマンドでの有効化に失敗しました。設定画面を開くので「リモートログイン」をオンにしてください。"
      open "x-apple.systempreferences:com.apple.Sharing-Settings.extension" 2>/dev/null \
        || open "/System/Library/PreferencePanes/SharingPref.prefPane"
      read -r -p "オンにしたら Enter を押してください: " _
    fi

  elif [ "$os_name" = "Linux" ]; then
    if ! command -v sshd >/dev/null 2>&1 && [ ! -x /usr/sbin/sshd ]; then
      info "openssh-server をインストールします"
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y openssh-server
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y openssh-server
      elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm openssh
      else
        die "パッケージマネージャーが判別できません。openssh-server を手動でインストールしてください。"
      fi
    fi
    # サービス名はディストリビューションにより ssh / sshd
    if systemctl list-unit-files 2>/dev/null | grep -q '^ssh\.service'; then
      sudo systemctl enable --now ssh
    else
      sudo systemctl enable --now sshd
    fi
    info "SSHサーバーを有効にしました。"
  else
    die "未対応のOSです: $os_name"
  fi

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  touch "$HOME/.ssh/authorized_keys"
  chmod 600 "$HOME/.ssh/authorized_keys"

  echo
  info "クライアント側で mkssh.sh を実行するときは、次の情報を使います:"
  echo "    ユーザー名 : $(whoami)"
  local ts
  if ts=$(find_tailscale); then
    echo "    Tailscale IP: $("$ts" ip -4 2>/dev/null | head -n1 || echo '取得できません（Tailscaleにログインしてください）')"
  else
    warn "tailscale コマンドが見つかりません。このPCにも Tailscale を入れてログインしてください。"
  fi
}

# ---------- メイン ----------
echo "このPCの役割を選んでください:"
echo "  1) クライアント（このPCから他のPCへ接続する）"
echo "  2) ホスト（他のPCからこのPCへ接続される）"
role=$(ask "番号")
case $role in
  1) setup_client ;;
  2) setup_host ;;
  *) die "1 か 2 を入力してください。" ;;
esac
