# PowerShell 7用の設定。.zshrc / .zsh_plugins / .zsh_prompt に相当する。

# -- 文字コード --
# 日本語版Windowsの既定はCP932のため、CLIの出力が文字化けしないようにする
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$OutputEncoding = [Text.UTF8Encoding]::new($false)

# -- 起動時の表示 --
$terminalGreeting = 'Hello'
$terminalGreetingFile = Join-Path $HOME '.config/dotfiles/terminal-greeting'
if (Test-Path -LiteralPath $terminalGreetingFile) {
  $savedGreeting = (Get-Content -LiteralPath $terminalGreetingFile -TotalCount 1 -Encoding utf8)
  if ($savedGreeting) { $terminalGreeting = $savedGreeting }
}
if (Get-Command figlet -ErrorAction SilentlyContinue) {
  figlet -c -- $terminalGreeting
} else {
  Write-Host $terminalGreeting
}
Remove-Variable terminalGreeting, terminalGreetingFile, savedGreeting -ErrorAction SilentlyContinue

# -- パス設定 --
$env:Path = "$HOME\.local\bin;$HOME\go\bin;$env:Path"

# -- エディタの設定 --
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'

# -- エイリアス設定 --
Set-Alias -Name vim -Value nvim
Set-Alias -Name vi -Value nvim

# -- nvim-treesitter --
# Visual Studio未導入の環境では、Scoopのmingwでパーサーをビルドする
if (-not (Get-Command cl -ErrorAction SilentlyContinue) -and (Get-Command gcc -ErrorAction SilentlyContinue)) {
  $env:CC = 'gcc'
}

# -- プロンプト設定 --
# ユーザー名、直近2階層のパス、Gitブランチ名を表示
function prompt {
  $esc = [char]27
  $path = $PWD.Path
  if ($path -eq $HOME) {
    $path = '~'
  } else {
    $path = (($path -split '[\\/]' | Where-Object { $_ }) | Select-Object -Last 2) -join '/'
  }
  $branch = git branch --show-current 2>$null
  $git = if ($branch) { "$esc[36m($branch)$esc[0m " } else { '' }
  "$esc[32m$env:USERNAME$esc[0m $path $git> "
}

# -- 履歴・補完(zsh-autosuggestions / history-substring-search / vi-mode相当) --
if (Get-Module -ListAvailable PSReadLine) {
  Set-PSReadLineOption -EditMode Vi -HistoryNoDuplicates -MaximumHistoryCount 10000
  # リダイレクト先など予測表示に対応しない環境では失敗するため、無視する
  try { Set-PSReadLineOption -PredictionSource History } catch { }

  foreach ($mode in 'Insert', 'Command') {
    # 上矢印キーとCtrl + Pで履歴検索、下矢印キーとCtrl + Nで逆方向(入力中の文字列で始まる履歴のみ)
    Set-PSReadLineKeyHandler -ViMode $mode -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -ViMode $mode -Key Ctrl+p -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -ViMode $mode -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -ViMode $mode -Key Ctrl+n -Function HistorySearchForward

    # naviをCtrl + gで呼び出し
    Set-PSReadLineKeyHandler -ViMode $mode -Key Ctrl+g -ScriptBlock {
      $command = navi --print
      if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
      }
    }
  }
}

# -- navi --
$env:NAVI_PATH = (Resolve-Path (Join-Path $PSScriptRoot '../cheats')).Path
$env:NAVI_CONFIG = (Resolve-Path (Join-Path $PSScriptRoot '../windows/navi-config.yaml')).Path

# -- yazi --
# ファイル種別の判定にGit同梱のfile.exeを使う
if (-not $env:YAZI_FILE_ONE) {
  $fileCommand = @(
    "$env:ProgramFiles\Git\usr\bin\file.exe",
    "$HOME\scoop\apps\git\current\usr\bin\file.exe"
  ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
  if ($fileCommand) { $env:YAZI_FILE_ONE = $fileCommand }
  Remove-Variable fileCommand -ErrorAction SilentlyContinue
}

function y {
  $tmp = (New-TemporaryFile).FullName
  yazi @args --cwd-file="$tmp"
  $cwd = Get-Content -LiteralPath $tmp -Encoding utf8 -Raw
  if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
    Set-Location -LiteralPath $cwd
  }
  Remove-Item -LiteralPath $tmp
}

# -- zoxide --
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (zoxide init powershell | Out-String)
}

# -- fzf(Ctrl + Tでファイル検索、Ctrl + Rで履歴検索) --
if (Get-Module -ListAvailable PSFzf) {
  Import-Module PSFzf
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}
