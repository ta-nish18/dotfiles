# Windows用セットアップ。
# 初回はPowerShell 7が未導入のため、Windows PowerShell 5.1でも動く構文だけを使う。
# 実行方法: powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
$ErrorActionPreference = 'Stop'

$dotfilesDir = $PSScriptRoot
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$backupRoot = Join-Path $HOME '.config\dotfiles-backups\pre-dotfiles'
$failures = New-Object System.Collections.ArrayList

# Scoopは管理者権限での実行を拒否するため、通常ユーザーのまま実行させる。
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw 'Run this script from a normal (non-administrator) PowerShell. Installers ask for UAC when needed.'
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw 'winget not found. Install or update "App Installer" from Microsoft Store.'
}

# インストーラーが更新したPATHを、現在のセッションへ反映する。
function Update-SessionPath {
  $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $user = [Environment]::GetEnvironmentVariable('Path', 'User')
  $env:Path = "$machine;$user"
}

function Write-TextFile($path, $content) {
  $parent = Split-Path -Parent $path
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  [IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

# 既存のファイルやディレクトリは削除せず、バックアップ先へ移動する。
function Move-ToBackup($path, $relativePath) {
  $destination = Join-Path $backupRoot $relativePath
  if (Test-Path -LiteralPath $destination) {
    $destination = "$destination.$(Get-Date -Format yyyyMMddHHmmss)"
  }
  $parent = Split-Path -Parent $destination
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  Move-Item -LiteralPath $path -Destination $destination
  Write-Host "Backed up: $path -> $destination"
}

# ジャンクションは開発者モードや管理者権限なしで作成できる。
function Set-DirectoryLink($source, $link, $backupPath) {
  $item = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
  if ($item) {
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
      if (@($item.Target) -contains $source) {
        return
      }
      # リンク自体だけを外す。リンク先の中身には触れない。
      [IO.Directory]::Delete($link)
    } else {
      Move-ToBackup $link $backupPath
    }
  }
  $parent = Split-Path -Parent $link
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  New-Item -ItemType Junction -Path $link -Target $source | Out-Null
  Write-Host "Linked: $link -> $source"
}

# PowerShell 5.1ではStopのままだと、外部コマンドのstderr出力で処理が止まる。
# 外部コマンドの成否は終了コードで判定する。
function Install-WingetPackage($id) {
  $ErrorActionPreference = 'Continue'
  # msstoreソースの接続エラーで全体が失敗しないよう、wingetソースだけを参照する
  & winget list --id $id --exact --source winget --accept-source-agreements *> $null
  if ($LASTEXITCODE -eq 0) {
    Write-Host "Already installed: $id"
    return
  }
  Write-Host "Installing: $id"
  & winget install --id $id --exact --source winget --silent --accept-package-agreements --accept-source-agreements
  if ($LASTEXITCODE -ne 0) {
    [void]$failures.Add(("winget: {0} (exit code 0x{1:X8})" -f $id, $LASTEXITCODE))
  }
}

function Install-ScoopPackage($name) {
  $ErrorActionPreference = 'Continue'
  $bucketless = ($name -split '/')[-1]
  if (Test-Path -LiteralPath (Join-Path $script:scoopRoot "apps\$bucketless")) {
    Write-Host "Already installed: $name"
    return
  }
  & scoop install $name
  if ($LASTEXITCODE -ne 0) {
    [void]$failures.Add("scoop: $name")
  }
}

# ターミナル起動時のメッセージは端末ごとのローカル設定として保存する。
$greetingFile = Join-Path $HOME '.config\dotfiles\terminal-greeting'
$greeting = 'Hello'
if (Test-Path -LiteralPath $greetingFile) {
  $saved = [IO.File]::ReadAllText($greetingFile).Trim()
  if ($saved) { $greeting = $saved }
}
$entered = Read-Host "Terminal greeting [$greeting]"
if ($entered) { $greeting = $entered }
Write-TextFile $greetingFile "$greeting`n"

# 基盤: Git(Scoopのbucket取得に必須)とPowerShell 7
Install-WingetPackage 'Git.Git'
Install-WingetPackage 'Microsoft.PowerShell'
Update-SessionPath

# CLIは管理者権限なしで導入できるScoopで管理する
$script:scoopRoot = if ($env:SCOOP) { $env:SCOOP } else { Join-Path $HOME 'scoop' }
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Write-Host 'Scoop not found. Installing from the official installer...'
  Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
  Update-SessionPath
}

foreach ($bucket in 'extras', 'nerd-fonts') {
  if (-not (Test-Path -LiteralPath (Join-Path $script:scoopRoot "buckets\$bucket"))) {
    $ErrorActionPreference = 'Continue'
    & scoop bucket add $bucket
    if ($LASTEXITCODE -ne 0) { [void]$failures.Add("scoop bucket: $bucket") }
    $ErrorActionPreference = 'Stop'
  }
}

$scoopPackages = @(
  'navi', 'fzf', 'figlet', 'yazi', 'ffmpeg', 'unar', '7zip', 'jq', 'poppler',
  'fd', 'ripgrep', 'zoxide', 'gh', 'nodejs', 'python', 'neovim', 'bat',
  'imagemagick', 'tree-sitter',
  # nvim-treesitterのパーサーのビルド、MiKTeXのlatexmkに必要
  'mingw', 'perl',
  'extras/lazygit', 'extras/wezterm', 'extras/sumatrapdf', 'extras/psfzf',
  'nerd-fonts/Hack-NF'
)
foreach ($package in $scoopPackages) {
  Install-ScoopPackage $package
}

# GUIアプリ。Skimの代替のSumatraPDFはScoop側で導入する。BetterDisplayはWindows版がない。
$wingetPackages = @(
  'OpenAI.ChatGPT', 'Anthropic.Claude', 'Google.GeminiDesktop',
  'Zen-Team.Zen-Browser', 'Zoom.Zoom', 'Tailscale.Tailscale',
  'Google.GoogleDrive', 'Logitech.OptionsPlus', 'MiKTeX.MiKTeX'
)
foreach ($package in $wingetPackages) {
  Install-WingetPackage $package
}
Update-SessionPath

# 設定のリンク
Set-DirectoryLink (Join-Path $dotfilesDir 'nvim') (Join-Path $env:LOCALAPPDATA 'nvim') 'localappdata\nvim'
Set-DirectoryLink (Join-Path $dotfilesDir 'wezterm') (Join-Path $HOME '.config\wezterm') 'config\wezterm'

# プロフィールの場所はOneDriveのフォルダーリダイレクトで変わるため、pwsh自身に尋ねる。
# ファイルのシンボリックリンクは権限が必要なので、リポジトリ内の設定を読み込むだけの1行を置く。
$pwsh = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
if (Test-Path -LiteralPath $pwsh) {
  $profilePath = (& $pwsh -NoProfile -Command '$PROFILE.CurrentUserAllHosts').Trim()
  $profileContent = ". '$((Join-Path $dotfilesDir 'shell\profile.ps1').Replace("'", "''"))'`n"
  $current = if (Test-Path -LiteralPath $profilePath) { [IO.File]::ReadAllText($profilePath) } else { $null }
  if ($current -ne $profileContent) {
    if ($null -ne $current) { Move-ToBackup $profilePath 'powershell\profile.ps1' }
    Write-TextFile $profilePath $profileContent
    Write-Host "Updated: $profilePath"
  }
} else {
  [void]$failures.Add('PowerShell 7 not found: profile was not installed')
}

# 共通指示と各LLMの専門指示を結合して、各ツールの標準パスへ配置する
$llmTargets = @(
  @{ Source = 'codex.md'; Generated = 'codex-AGENTS.md'; Destination = '.codex\AGENTS.md' },
  @{ Source = 'claude.md'; Generated = 'claude-CLAUDE.md'; Destination = '.claude\CLAUDE.md' },
  @{ Source = 'gemini.md'; Generated = 'gemini-GEMINI.md'; Destination = '.gemini\GEMINI.md' }
)
$commonInstructions = [IO.File]::ReadAllText((Join-Path $dotfilesDir 'llm\common.md'))
foreach ($target in $llmTargets) {
  $specialized = [IO.File]::ReadAllText((Join-Path $dotfilesDir "llm\$($target.Source)"))
  $rendered = "$commonInstructions`n$specialized"
  Write-TextFile (Join-Path $dotfilesDir "llm\generated\$($target.Generated)") $rendered

  $destination = Join-Path $HOME $target.Destination
  $current = if (Test-Path -LiteralPath $destination) { [IO.File]::ReadAllText($destination) } else { $null }
  if ($current -ne $rendered) {
    if ($null -ne $current) { Move-ToBackup $destination ($target.Destination) }
    Write-TextFile $destination $rendered
    Write-Host "Updated: $destination"
  }
}

if ($failures.Count -gt 0) {
  Write-Warning 'Some steps failed. Fix the cause and run this script again:'
  $failures | ForEach-Object { Write-Warning "  $_" }
  exit 1
}
Write-Host 'Done! Open WezTerm to start using the new environment.'
