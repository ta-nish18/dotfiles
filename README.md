# dotfiles

ターミナルとNeovimを中心としたmacOS開発環境を構築するdotfilesです。Apple Silicon MacとIntel Macの両方に対応しています。

## 構築される環境

| 領域 | 内容 |
| --- | --- |
| セットアップ基盤 | HomebrewとAnsibleを準備し、パッケージ・設定・シンボリックリンクを適用 |
| シェル | Zsh、Sheldon、補完、履歴検索、fzf、zoxide、navi、yazi連携 |
| ターミナル | Ghosttyのテーマ、フォント、ペイン操作、ウィンドウ設定 |
| エディタ | Neovim、LSP、補完、整形、Git連携、ファイル検索、ターミナル統合 |
| Python開発 | Pyright、Ruff、プロジェクト内`.venv`の自動選択、現在ファイルの実行 |
| MATLAB開発 | MATLAB Language Server、インストール済みMATLABの自動検出、`.m`ファイルの実行 |
| LaTeX執筆 | BasicTeX、latexmk、VimTeX、TexLab、Skimによる継続コンパイルとPDF表示 |
| 共通設定 | naviチートシート、Codex・Claude Code・Gemini CLIの共通／専門指示、Hack Nerd Font |

## インストールされるアプリ

既にインストール済みのGUIアプリは上書きせず、不足しているものだけをHomebrew Caskで導入します。

| 分類 | アプリ |
| --- | --- |
| AI | ChatGPT、Claude、Gemini Desktop（Apple Silicon・macOS 15以降） |
| ターミナル | Ghostty |
| ブラウザ | Zen Browser |
| コミュニケーション | Zoom |
| ネットワーク・同期 | Tailscale、Google Drive（macOS 13以降） |
| PDF | Skim |
| 周辺機器 | Logi Options+、BetterDisplay |

## インストールされるCLI

| 用途 | ツール |
| --- | --- |
| 検索・移動 | `fzf`、`fd`、`ripgrep`、`zoxide` |
| ファイル操作・表示 | `yazi`、`bat`、`unar`、`jq`、`poppler`、ImageMagick |
| ターミナル補助 | `navi`、`figlet`、`thefuck` |
| Git | `gh`、`lazygit` |
| 開発環境 | `node`、`python`、`nvim`、`tree-sitter-cli` |
| LaTeX | BasicTeX、`latexmk` |
| シェル管理 | `sheldon` |
| メディア補助 | `ffmpegthumbnailer` |

## Neovim環境

- Leaderキーは`Space`
- Python、MATLAB、Go、Lua、TypeScript、CSS、YAMLのLanguage Serverを利用
- Telescopeによるファイル・文字列・バッファ検索
- Neo-treeによるファイルツリー
- Ruffなどによる保存時の自動整形
- 補完、診断、定義ジャンプ、参照検索、名前変更、コードアクション
- LazyGit、フローティングターミナル、Git差分表示
- Copilot、TODO検索、Markdown表示、画像貼り付け
- Pythonはプロジェクト直下の`.venv/bin/python`を優先
- MATLABは`MATLAB_ROOT`、またはインストール済みの最新リリースを自動検出
- LaTeXはVimTeXとTexLabを利用し、Skimでコンパイル結果を表示

主なキーは`Space`を押すとwhich-keyに表示されます。PythonまたはMATLABの現在ファイルは`Space r r`で保存して実行できます。

LaTeXファイルでは`Space l c`で継続コンパイルを開始すると、以後は保存するたびにPDFが更新されます。`Space l v`でPDFを表示し、`Space l s`でコンパイラを停止します。

## LLM指示

`llm/common.md`を3つのLLMで共有し、Codexは実装・レビュー、Claude Codeは設計・仕様整理、Gemini CLIは調査・情報統合を専門指示として追加します。セットアップ時に内容を結合して、`~/.codex/AGENTS.md`、`~/.claude/CLAUDE.md`、`~/.gemini/GEMINI.md`へ配置します。

これらはCodex、Claude Code、Gemini CLI向けの指示です。ClaudeおよびGeminiのデスクトップアプリに対する設定ではありません。

## セットアップ

macOSの管理者権限とインターネット接続が必要です。リポジトリを任意の場所へ配置し、次を実行します。

```sh
cd /path/to/dotfiles
./install.sh
```

Homebrewがない場合は公式インストーラーから導入し、続いてAnsibleと各パッケージを準備します。セットアップ中に、管理者パスワードとターミナル起動時のメッセージを入力します。

TailscaleとGoogle Driveはインストールのみを行います。接続先や同期対象はアプリの初回起動時に設定します。Tailscaleの初回起動時は、macOSの「プライバシーとセキュリティ」で許可が必要になる場合があります。LaTeXは軽量なBasicTeXを導入し、文書固有の追加パッケージは必要に応じてTeX Live Managerで追加できます。

ターミナルメッセージの初回既定値は`Hello`です。端末ごとの`~/.config/dotfiles/terminal-greeting`へ保存され、Gitでは管理されません。再セットアップ時にEnterだけを押すと現在値を維持します。

## SSH接続のセットアップ（Tailscale経由）

`install.sh`はTailscaleアプリに同梱されたCLIを`~/.local/bin/tailscale`から呼べるようにします。その後、各PCで次を実行します。

```sh
./mkssh.sh
```

最初に役割を選びます。

- **ホスト（接続される側）**：SSHサーバー（macOSはリモートログイン）を有効化し、ユーザー名とTailscale IPを表示します。先にこちらを実行します。
- **クライアント（接続する側）**：鍵ファイル名とパスフレーズを入力して鍵を作成し、`tailscale status`の一覧から接続先を選び、ユーザー名を入力して公開鍵をコピーします。最後に`ssh <id>`の`id`を決めると`~/.ssh/config`へ追記し、接続テストを行います。

`~/.ssh/config`は追記前に`config.bak.<日時>`へ退避します。秘密鍵はリポジトリに含まれません。

## 既存設定の保護

置換対象の既存設定は、初回適用時に次の場所へバックアップします。

```text
~/.config/dotfiles-backups/pre-dotfiles/
```

対象はZsh、Ghostty、Neovim、LLM指示、naviの設定です。各対象のバックアップは一度だけ作成し、再実行では上書きしません。その後、リポジトリ内の設定を各配置先へ反映します。

## リポジトリ構成

| パス | 内容 |
| --- | --- |
| `ansible/` | パッケージと設定リンクの適用 |
| `nvim/` | Neovimとプラグイン設定 |
| `shell/` | Zsh、関数、プロンプト、プラグイン設定 |
| `ghostty/` | Ghosttyの共通・macOS設定 |
| `sheldon/` | Zshプラグイン定義 |
| `cheats/` | naviのカスタムチートシート |
| `llm/` | 3つのLLMで共有する指示と各LLMの専門指示 |
| `scripts/` | 既存設定のバックアップ処理 |
| `mkssh.sh` | Tailscale経由のSSH鍵・接続設定 |
| `install.ps1`、`mkssh.ps1` | Windows用のセットアップとSSH設定 |
| `wezterm/`、`windows/`、`shell/profile.ps1` | Windows用のターミナル、navi、PowerShell設定 |

## Windows版

Windows 10/11向けのセットアップです。Ansibleの代わりに`install.ps1`、zshの代わりにPowerShell 7、Ghosttyの代わりにWezTermを使います。Neovim設定、naviチートシート、LLM指示はmacOSと共有します。

まず通常権限のPowerShellでGitを導入し、新しいウィンドウでリポジトリを取得して実行します。ブラウザでダウンロードしたZIPではなく`git clone`を使ってください。

```powershell
winget install --id Git.Git --exact
```

```powershell
git clone <このリポジトリのURL> dotfiles
```

```powershell
cd dotfiles
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

CLIはScoop、GUIアプリはwingetで導入します。Scoopの制約により、管理者権限のPowerShellでは実行できません。既存の設定は`~/.config/dotfiles-backups/pre-dotfiles/`へ移動します。

### macOS版との違い

| macOS | Windows | 補足 |
| --- | --- | --- |
| Ansible / Homebrew | `install.ps1` / Scoop・winget | Ansibleの制御ノードはWindowsで動作しない |
| Ghostty | WezTerm | Ghosttyに公式Windows版がない |
| `super`+`h/j/k/l` | `Alt`+`h/j/k/l` | `Win`+`L`などはOSの予約キー。ペイン幅の均等化は未対応 |
| zsh / sheldon | PowerShell 7 / PSReadLine・PSFzf | 履歴検索は部分一致ではなく前方一致 |
| Skim | SumatraPDF | 逆検索は`nvim/`ではなくSumatraPDF側で設定する |
| BasicTeX | MiKTeX、Perl | |
| `ffmpegthumbnailer` | `ffmpeg`、`7zip` | yaziのプレビュー用 |

次の機能はWindowsでは利用できません。

- `thefuck`：Scoopに収録されていないため導入しません
- BetterDisplay：Windows版がありません
- image.nvim：`ioctl`に依存するため無効にしています（Markdown内の画像表示のみ影響）
- naviチートの一部：`awk`、`xargs`、`grep`、`head`を使うチートはPowerShellでは動作しません

### SSH接続

各PCで`mkssh.ps1`を実行します。ホスト側は管理者のPowerShellが必要です。Windowsホストへの公開鍵はコピーできないため、クライアントに表示された公開鍵をホスト側の`mkssh.ps1`へ貼り付けます。OpenSSHサーバーはTailscale以外のネットワークからも到達できる設定で有効になります。

## 公開範囲

このリポジトリはPublicでの利用を前提とし、共有可能な設定だけを管理します。パスワード、APIキー、Cookie、秘密鍵、ブラウザの履歴・セッション、会社固有情報、Codexの端末固有設定は含めません。
