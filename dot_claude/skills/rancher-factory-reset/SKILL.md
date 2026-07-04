---
name: rancher-factory-reset
description: >-
  Rancher Desktop を factory-reset して完全初期化し、無人で再起動するスキル。VM・全コンテナ
  /イメージ/ボリューム/ビルドキャッシュ・K8s イメージキャッシュ・設定をすべて削除し、
  `rdctl start` で headless 起動して `docker info` が通るまで待つ。docker / nerdctl が
  壊れた・残骸を完全に消したい・まっさらからやり直したい時に使う。ユーザーが
  `/rancher-factory-reset` で呼んだ時、または「docker 完全削除」「docker 全消し」「rancher
  リセット」「rancher 初期化」「factory reset」のように Rancher Desktop / docker 環境を
  まるごと初期化して作り直したい意図を示した時に使う。破壊的操作は呼び出しをもって同意済みと
  みなし、確認プロンプトは出さず自律実行する。
user-invocable: true
allowed-tools: Bash
---

# rancher-factory-reset

Rancher Desktop を factory-reset して完全初期化し、そのまま無人で再起動するオーケストレーター。
VM ごと破棄するため、全コンテナ・全イメージ・全ボリューム・ビルドキャッシュが消える。
完了判定は `docker info` が通ること。Kubernetes は無効化して起動する。

## 前提

- macOS + Rancher Desktop（標準の `/Applications/Rancher Desktop.app` にインストールされている前提）。
- factory-reset は `~/.rd/bin`（docker / rdctl などの PATH 連携 symlink）ごと削除する。reset 後は
  bare の `rdctl` / `docker` が command not found になるため、本スキルは全コマンドをアプリ同梱の
  絶対パス（各コードブロック冒頭で定義する `APP_BIN`）で呼び、PATH 連携に依存しない。`~/.rd/bin`
  は手順3の `rdctl start`（`--application.path-management-strategy rcfiles`）で再生成され、完了後は
  ユーザーの通常の bare コマンドも復活する。
- container engine は moby（dockerd）を使う構成。完了判定に `docker info` を使うため、
  リスタート時に engine を moby に固定する。

## 破壊的操作の前提（確認不要）

このスキルは Rancher Desktop の状態を不可逆に全削除する。呼び出された時点で破壊的操作すべてに
同意済みとみなす。確認は求めず、実行直前に何を消すかを1行表示してから進める。
（完全初期化が目的のスキルであり、削除はその不可分の一部のため）

## 実行手順

### 0. 前提チェック

`command -v rdctl` は `~/.rd/bin` 依存で reset 後は当てにならないため、アプリ同梱の絶対パスで
存在を確認する。

```bash
APP_BIN="/Applications/Rancher Desktop.app/Contents/Resources/resources/darwin/bin"
[ -x "$APP_BIN/rdctl" ] || { echo "RDCTL_MISSING"; exit 1; }
```

`RDCTL_MISSING` の場合は処理を止め、Rancher Desktop が `/Applications` にインストールされて
いるかをユーザーに確認してもらう。アプリの起動状態は確認しない（不問）—— 同梱 rdctl さえ
あれば、アプリが停止中でもそのまま次の手順へ進む。

### 1. 削除内容の明示（プロンプトは出さない）

```bash
echo "これから Rancher Desktop を factory-reset します: VM・全コンテナ/イメージ/ボリューム/ビルドキャッシュ・K8sキャッシュ・設定をすべて削除して再起動します（不可逆）"
```

### 2. factory-reset（破壊）

`factory-reset` サブコマンドは deprecated なので、非推奨でない `reset --factory` を使う。
`--factory` は VM と K8s ワークロードを消すが K8s イメージキャッシュは含まないため、
完全消去のために `--cache` も付ける。

```bash
APP_BIN="/Applications/Rancher Desktop.app/Contents/Resources/resources/darwin/bin"
"$APP_BIN/rdctl" reset --factory --cache
```

このコマンドはアプリが起動中でも停止中でも、状態を問わずそのまま実行してよい（先にアプリを
起動し直す必要はない）。`rdctl reset --factory` は実行中アプリの停止も含めて状態を初期化し、
停止状態でもリカバリ用途として動作する。実行後は次回起動時に初回セットアップが必要な状態に戻る。

このコマンドが非ゼロ終了したら、後続の手順3（start）・手順4（ポーリング）には進まず、エラー
出力をそのまま添えて「初期化に失敗した・環境は初期化されていない可能性が高い」と正直に報告して
停止する。ここで自動再試行はしない —— 破壊操作なので再実行するかはユーザーが決め、ユーザーが
再実行を選んだら手順2からやり直す。`failed to connect to backend` 等でバックエンドに繋がらない
場合の再実行候補として、`open -a "Rancher Desktop"` で一度 GUI を起動しバックエンドが立ち上がって
から `"$APP_BIN/rdctl" reset --factory --cache` を再試行する、または GUI の Troubleshooting →
Factory Reset を使う、をユーザーに案内する。

### 3. headless 再起動（初回ダイアログを事前回答）

`reset --factory` 後は初回セットアップダイアログが出る状態になる。`rdctl start` に設定フラグを
渡して非対話で起動し、ダイアログを事前回答する。`docker info` を完了判定に使うため engine は
moby に固定する。

```bash
APP_BIN="/Applications/Rancher Desktop.app/Contents/Resources/resources/darwin/bin"
"$APP_BIN/rdctl" start \
  --container-engine.name moby \
  --kubernetes.enabled=false \
  --application.telemetry.enabled=false \
  --application.path-management-strategy rcfiles
```

- `--container-engine.name moby`: `docker info` を完了判定に使うため moby を明示（現行構成に整合）。
- `--kubernetes.enabled=false`: Kubernetes は使わないため無効化して起動する。
- `--application.telemetry.enabled=false` / `--application.path-management-strategy rcfiles`:
  初回ダイアログの設問を事前回答して無人起動させる。

### 4. 起動完了待ち（docker info ポーリング）

`docker info` が通った時点で完了とみなす。factory-reset 後は VM 再プロビジョニング
（再ダウンロード含む）で数分かかるため、タイムアウトは長めに取る。K8s の Ready は待たない。

```bash
APP_BIN="/Applications/Rancher Desktop.app/Contents/Resources/resources/darwin/bin"
start=$SECONDS; ok=0
while [ $((SECONDS - start)) -lt 480 ]; do
  if "$APP_BIN/docker" info >/dev/null 2>&1; then ok=1; break; fi
  sleep 5
done
elapsed=$((SECONDS - start))
if [ "$ok" = 1 ]; then echo "READY (${elapsed}s)"; else echo "NOT_READY (${elapsed}s)"; fi
```

### 5. 完了報告 / フォールバック

`READY` / `NOT_READY` に応じて分岐する。

| 結果 | 意味 | 対応 |
|---|---|---|
| `READY` | docker エンジン使用可能 | 経過秒とともに完了を報告。`docker info` が通る状態を確認済みと伝える |
| `NOT_READY` | 8分以内に `docker info` が通らない | 初回ダイアログが GUI 側でブロックしている可能性がある。`open -a "Rancher Desktop"` で GUI を開き、初回セットアップが残っていれば完了してもらってから手順4を再実行する。docker 側のプロビジョニング失敗も疑い、`"$APP_BIN/rdctl" info` / GUI のログを確認して原因を報告する |

## 注意

- `factory-reset` サブコマンドは deprecated。常に `rdctl reset --factory` を使う。
- 破壊は呼び出し=同意。確認なしで `reset --factory --cache` を実行する。
- engine を moby に固定するのは `docker info` を完了判定に使うため（現行構成が moby のため整合）。
  純粋なデフォルト復帰にしたい場合は `--container-engine.name moby` を外す（ただし default が
  containerd だと `docker info` が完了判定に使えなくなる点に注意）。現在 containerd で運用している
  場合、このスキルは実行後に engine を moby へ切り替える副作用がある。containerd へ戻すには
  `rdctl set --container-engine.name containerd` を実行する。
- 完了判定は `docker info` のみ。Kubernetes は `--kubernetes.enabled=false` で無効化して起動するため
  Ready 待ちも再ダウンロードも発生しない（`--cache` で K8s イメージも消える）。
- 各ステップで失敗があれば、その出力とともに正直に報告する（成功を装わない）。
