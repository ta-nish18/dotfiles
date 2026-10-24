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
| 共通設定 | naviチートシート、Codex共通指示、Hack Nerd Font・SF Pro・SF Mono |

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

## インストールされるCLI

| 用途 | ツール |
| --- | --- |
| 検索・移動 | `fzf`、`fd`、`ripgrep`、`zoxide` |
| ファイル操作・表示 | `yazi`、`bat`、`unar`、`jq`、`poppler`、`lz4`、ImageMagick |
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

## セットアップ

macOSの管理者権限とインターネット接続が必要です。リポジトリを任意の場所へ配置し、次を実行します。

```sh
cd /path/to/dotfiles
./install.sh
```

Homebrewがない場合は公式インストーラーから導入し、続いてAnsibleと各パッケージを準備します。セットアップ中に、管理者パスワードとターミナル起動時のメッセージを入力します。

TailscaleとGoogle Driveはインストールのみを行います。接続先や同期対象はアプリの初回起動時に設定します。Tailscaleの初回起動時は、macOSの「プライバシーとセキュリティ」で許可が必要になる場合があります。LaTeXは軽量なBasicTeXを導入し、文書固有の追加パッケージは必要に応じてTeX Live Managerで追加できます。

ターミナルメッセージの初回既定値は`Hello`です。端末ごとの`~/.config/dotfiles/terminal-greeting`へ保存され、Gitでは管理されません。再セットアップ時にEnterだけを押すと現在値を維持します。

## 既存設定の保護

置換対象の既存設定は、初回適用時に次の場所へバックアップします。

```text
~/.config/dotfiles-backups/pre-dotfiles/
```

対象はZsh、Ghostty、Neovim、Codex、naviの設定です。バックアップは初回だけ作成し、再実行では上書きしません。その後、リポジトリ内の設定を各配置先へシンボリックリンクします。

## リポジトリ構成

| パス | 内容 |
| --- | --- |
| `ansible/` | パッケージと設定リンクの適用 |
| `nvim/` | Neovimとプラグイン設定 |
| `shell/` | Zsh、関数、プロンプト、プラグイン設定 |
| `ghostty/` | Ghosttyの共通・macOS設定 |
| `sheldon/` | Zshプラグイン定義 |
| `cheats/` | naviのカスタムチートシート |
| `codex/` | Codex共通指示 |
| `scripts/` | 既存設定のバックアップ処理 |

## 公開範囲

このリポジトリはPublicでの利用を前提とし、共有可能な設定だけを管理します。パスワード、APIキー、Cookie、秘密鍵、ブラウザの履歴・セッション、会社固有情報、Codexの端末固有設定は含めません。
