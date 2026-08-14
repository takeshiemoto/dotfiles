<!-- markdownlint-disable MD013 -->

# dotfiles

![dotfiles hero](https://github.com/user-attachments/assets/4e7240e1-ea61-470c-a34e-5f0bf4491b55)

[chezmoi](https://www.chezmoi.io/) で管理する macOS 用 dotfiles。まっさらな Mac をコマンド 1 つで普段の開発環境に戻す。

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-000000?logo=apple&logoColor=white&style=flat-square)](https://www.apple.com/macos/) [![chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-1D89C8?style=flat-square)](https://www.chezmoi.io/) [![zsh](https://img.shields.io/badge/shell-zsh-F15A24?style=flat-square)](https://www.zsh.org/) [![Neovim](https://img.shields.io/badge/editor-LazyVim-57A143?logo=neovim&logoColor=white&style=flat-square)](https://www.lazyvim.org/) [![WezTerm](https://img.shields.io/badge/terminal-WezTerm-4E49EE?style=flat-square)](https://wezterm.org/)

## クイックスタート

まっさらな Mac で実行する。

```sh
curl -fsSL https://raw.githubusercontent.com/takeshiemoto/dotfiles/main/bootstrap.sh -o /tmp/bootstrap.sh && bash /tmp/bootstrap.sh
```

chezmoi が既にあるマシンでは `chezmoi init --apply takeshiemoto` で足りる。既存環境に重ねる場合は、先に `chezmoi diff` で差分を確認する。

初回の `chezmoi init` では git の name / email と、cask（GUI アプリ・フォント）ごとの導入可否を対話で聞かれる。回答は `~/.config/chezmoi/chezmoi.toml` に保存され、以後は聞かれない。CLI 系ツールは設定ファイルが依存するため質問なしで入る。

## 初回セットアップチェックリスト

bootstrap が自動化できない手順。上から順に済ませる。

1. Karabiner-Elements: システム設定でドライバ拡張と入力監視を許可する
2. サインイン: `claude` を起動して `/login` する（プラグインのインストール確認が出る）。続けて `codex`、Slack、Rancher Desktop
3. 外部スキルの復元:

   ```sh
   npx -y skills add mattpocock/skills -g --skill grill-me --skill grill-with-docs -y
   npx -y skills add iKora128/stop-ai-slop-jp -g -y
   ```

4. Git identity: init 時の回答から設定される。変える場合は `~/.gitconfig.local` に上書きを書くか、`~/.config/chezmoi/chezmoi.toml` の `[data]` を編集して再 apply する
5. Langfuse（任意）: セルフホストを起動し、そのプロジェクトの public key を `~/.claude/settings.json` の `pluginConfigs` に設定する。使わないなら `langfuse-observability` プラグインを無効にする
6. ghq 配下で source を管理する場合: `ghq get takeshiemoto/dotfiles` の後、`~/.config/chezmoi/chezmoi.toml` の最上位（`[data]` より上）に次を書き、`chezmoi source-path` で確認する

   ```toml
   sourceDir = "/Users/<you>/ghq/github.com/takeshiemoto/dotfiles"
   ```

7. 再ログインする（キーボード設定の反映）

## 日常の操作

```sh
chezmoi diff          # 何が変わるかを見る
chezmoi add <file>    # ライブの編集をリポジトリに取り込む
chezmoi apply         # リポジトリの状態を反映する
chezmoi cd            # ソースリポジトリに移動する
```

cask の導入可否を後から変えるには `~/.config/chezmoi/chezmoi.toml` の `[data.install]` を編集して `chezmoi apply` する。true にすれば次の apply で入るが、false にしても導入済みのものはアンインストールされない。

リポジトリの設計と規約は `AGENTS.md` にある。
