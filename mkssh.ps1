# Tailscale経由のSSH接続をセットアップする(mkssh.shのWindows版)。
#   クライアント側: 鍵の作成 → 接続先の選択 → 公開鍵のコピー → ~/.ssh/config への追記
#   ホスト側      : OpenSSHサーバーの有効化(管理者のPowerShellで実行)
# 外部コマンドの成否は終了コードで判定する(5.1ではStopだとstderr出力で止まるため)
$ErrorActionPreference = 'Continue'

function Write-Info($message) { Write-Host "==> $message" -ForegroundColor Blue }

function Read-Answer($prompt, $default) {
  $label = if ($default) { "$prompt [$default]" } else { $prompt }
  $answer = Read-Host $label
  if ($answer) { return $answer }
  return $default
}

function Confirm-Answer($prompt) {
  return (Read-Host "$prompt [y/N]") -match '^(y|yes)$'
}

function Find-Tailscale {
  $command = Get-Command tailscale -ErrorAction SilentlyContinue
  if ($command) { return $command.Source }
  $bundled = Join-Path $env:ProgramFiles 'Tailscale\tailscale.exe'
  if (Test-Path -LiteralPath $bundled) { return $bundled }
  return $null
}

# ---------- クライアント側 ----------
function Start-ClientSetup {
  $tailscale = Find-Tailscale
  if (-not $tailscale) {
    throw 'tailscale コマンドが見つかりません。先に install.ps1 を実行してください。'
  }

  $sshDir = Join-Path $HOME '.ssh'
  New-Item -ItemType Directory -Path $sshDir -Force | Out-Null

  # 1. 鍵の作成
  Write-Info 'SSHキーを準備します'
  while ($true) {
    $keyName = Read-Answer '鍵のファイル名(~/.ssh/ 以下)' 'id_ed25519'
    if ($keyName -match '[\\/]') {
      Write-Warning 'ファイル名だけを入力してください。'
      continue
    }
    $keyPath = Join-Path $sshDir $keyName
    if (Test-Path -LiteralPath $keyPath) {
      if (Confirm-Answer "$keyPath は既にあります。この鍵をそのまま使いますか?") { break }
      continue
    }
    # パスフレーズはssh-keygen自身に質問させる(コマンドライン引数に残さないため)
    Write-Host '続けてパスフレーズを聞かれます。空のままEnterでパスフレーズなしになります。'
    & ssh-keygen -t ed25519 -f $keyPath -C "$env:USERNAME@$env:COMPUTERNAME"
    if ($LASTEXITCODE -ne 0) { throw 'ssh-keygen に失敗しました。' }
    break
  }
  $publicKeyPath = "$keyPath.pub"
  if (-not (Test-Path -LiteralPath $publicKeyPath)) { throw "公開鍵 $publicKeyPath が見つかりません。" }

  # 2. 接続先の選択
  Write-Info 'Tailscale のデバイス一覧を取得します'
  $selfIp = (& $tailscale ip -4 2>$null | Select-Object -First 1)
  $statusLines = & $tailscale status 2>$null
  if ($LASTEXITCODE -ne 0) { throw 'tailscale status に失敗しました。Tailscale にログインしているか確認してください。' }

  $devices = @()
  foreach ($line in $statusLines) {
    $fields = -split $line
    if ($fields.Count -ge 4 -and $fields[0] -match '^100\.' -and $fields[0] -ne $selfIp) {
      $devices += [pscustomobject]@{
        No    = $devices.Count + 1
        IP    = $fields[0]
        Name  = $fields[1]
        OS    = $fields[3]
        State = if ($fields.Count -ge 5) { $fields[4] } else { '' }
      }
    }
  }
  if ($devices.Count -eq 0) { throw '接続できる他のデバイスが見つかりません。' }
  $devices | Format-Table -AutoSize | Out-Host

  while ($true) {
    $choice = Read-Host '接続先の番号'
    if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $devices.Count) { break }
    Write-Warning "1〜$($devices.Count) の番号を入力してください。"
  }
  $target = $devices[[int]$choice - 1]
  Write-Info "選択: $($target.Name) ($($target.IP))"

  # 3. ユーザー名
  $remoteUser = Read-Answer '接続先のユーザー名' $env:USERNAME

  # 4. 公開鍵のコピー
  $publicKey = ([IO.File]::ReadAllText($publicKeyPath)).Trim()
  if ($target.OS -eq 'windows') {
    # Windowsホストはシェルと鍵の置き場所が異なるため、ホスト側のmkssh.ps1で登録する
    Write-Info '接続先で mkssh.ps1 のホスト側を実行し、次の公開鍵を貼り付けてください:'
    Write-Host $publicKey
    Read-Host '登録したら Enter を押してください' | Out-Null
  } else {
    Write-Info "公開鍵を $remoteUser@$($target.IP) にコピーします(接続先のログインパスワードを聞かれます)"
    # WindowsのパイプはCRLFを付けるため、接続先で取り除く
    $publicKey | & ssh "$remoteUser@$($target.IP)" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && tr -d '\r' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    if ($LASTEXITCODE -ne 0) { throw '公開鍵のコピーに失敗しました。' }
  }

  # 5. ~/.ssh/config への追記
  $config = Join-Path $sshDir 'config'
  if (-not (Test-Path -LiteralPath $config)) { New-Item -ItemType File -Path $config | Out-Null }
  $configText = [IO.File]::ReadAllText($config)
  while ($true) {
    $hostAlias = Read-Answer 'ssh [id] で使う id' $target.Name
    if ($hostAlias -notmatch '^[A-Za-z0-9._-]+$') {
      Write-Warning '英数字と . _ - だけで入力してください。'
      continue
    }
    if ($configText -match "(?im)^\s*Host\s+(.*\s)?$([regex]::Escape($hostAlias))(\s|$)") {
      Write-Warning "Host $hostAlias は既に $config にあります。"
      continue
    }
    break
  }

  Copy-Item -LiteralPath $config -Destination "$config.bak.$(Get-Date -Format yyyyMMddHHmmss)"
  $entry = @()
  if ($configText.Length -gt 0) { $entry += '' }
  $entry += "# mkssh.ps1 で追加 ($(Get-Date -Format yyyy-MM-dd))"
  $entry += "Host $hostAlias"
  $entry += "    HostName $($target.IP)"
  $entry += "    User $remoteUser"
  $entry += "    IdentityFile ~/.ssh/$keyName"
  $entry += '    IdentitiesOnly yes'
  $entry += '    ServerAliveInterval 60'
  # ssh-agentサービスは既定で無効のため、動いている場合だけ使う
  $agent = Get-Service ssh-agent -ErrorAction SilentlyContinue
  if ($agent -and $agent.Status -eq 'Running') { $entry += '    AddKeysToAgent yes' }
  # BOM付きのconfigはsshが読めないため、BOMなしで追記する
  [IO.File]::AppendAllText($config, (($entry -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
  Write-Info "$config に Host $hostAlias を追加しました(元のファイルは .bak に退避)"

  # 6. 接続テスト
  Write-Info "接続テスト: ssh $hostAlias"
  & ssh -o ConnectTimeout=10 $hostAlias 'echo connected'
  if ($LASTEXITCODE -eq 0) {
    Write-Info "完了しました。今後は ssh $hostAlias で接続できます。"
  } else {
    Write-Warning '接続テストに失敗しました。接続先のホスト側設定が済んでいるか確認してください。'
  }
}

# ---------- ホスト側 ----------
function Start-HostSetup {
  $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'ホスト側の設定は管理者のPowerShellで実行してください。'
  }

  Write-Info 'このPCへのSSH接続を有効にします'
  $capability = Get-WindowsCapability -Online -Name 'OpenSSH.Server*' | Select-Object -First 1
  if ($capability.State -ne 'Installed') {
    Write-Info 'OpenSSHサーバーをインストールします'
    Add-WindowsCapability -Online -Name $capability.Name | Out-Null
  }
  Set-Service -Name sshd -StartupType Automatic
  Start-Service -Name sshd

  if (-not (Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' `
      -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
  }

  # 既定のcmd.exeではなくPowerShell 7でログインさせる
  $pwsh = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
  if ((Test-Path -LiteralPath $pwsh) -and (Confirm-Answer 'SSHログイン時のシェルをPowerShell 7にしますか?')) {
    New-Item -Path 'HKLM:\SOFTWARE\OpenSSH' -Force | Out-Null
    New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value $pwsh -PropertyType String -Force | Out-Null
  }

  # 管理者ユーザーの鍵は~/.sshではなくこのファイルだけが参照される
  $authorizedKeys = Join-Path $env:ProgramData 'ssh\administrators_authorized_keys'
  if (-not (Test-Path -LiteralPath $authorizedKeys)) { New-Item -ItemType File -Path $authorizedKeys -Force | Out-Null }
  & icacls $authorizedKeys /inheritance:r /grant 'Administrators:F' /grant 'SYSTEM:F' | Out-Null

  $publicKey = Read-Host 'クライアントの公開鍵を貼り付けてください(後で登録する場合は空のままEnter)'
  if ($publicKey) {
    if ($publicKey -notmatch '^(ssh-|ecdsa-|sk-)') { throw '公開鍵の形式ではありません。' }
    $existing = [IO.File]::ReadAllText($authorizedKeys)
    if (-not $existing.Contains($publicKey)) {
      [IO.File]::AppendAllText($authorizedKeys, "$publicKey`n", (New-Object System.Text.UTF8Encoding($false)))
    }
    Write-Info '公開鍵を登録しました。'
  }

  Write-Host ''
  Write-Info 'クライアント側で mkssh を実行するときは、次の情報を使います:'
  Write-Host "    ユーザー名 : $env:USERNAME"
  $tailscale = Find-Tailscale
  if ($tailscale) {
    Write-Host "    Tailscale IP: $(& $tailscale ip -4 2>$null | Select-Object -First 1)"
  } else {
    Write-Warning 'tailscale コマンドが見つかりません。このPCにも Tailscale を入れてログインしてください。'
  }
}

# ---------- メイン ----------
Write-Host 'このPCの役割を選んでください:'
Write-Host '  1) クライアント(このPCから他のPCへ接続する)'
Write-Host '  2) ホスト(他のPCからこのPCへ接続される)'
switch (Read-Host '番号') {
  '1' { Start-ClientSetup }
  '2' { Start-HostSetup }
  default { throw '1 か 2 を入力してください。' }
}
