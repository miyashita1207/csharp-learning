# 00-setup

## GitHub Actionsのワークフローの作り方

GitHub Wikiと `notes/` 内の `.md` ファイルを自動同期するために、AIにGitHub Actionsを用いたワークフローを作成してもらった

`sync-wiki.sh` と `sync-wiki.yml` を作ってもらった

## `yml` (`yaml`) の書き方

そもそも、`yml` (`yaml`) は**構造化データを人間が読みやすく、かつコンピュータにも解釈しやすいように記述するためのデータシリアライズ言語・フォーマット**（**Y**AML **A**in't **M**arkup **L**anguageの略）

### 基本ルール

- `キー: 値` の形でデータを書く（コロンの後ろに半角スペースが必要）
- 階層は**インデント（半角スペース）**で表す（タブ文字は使えない）
- `-` で始まる行はリスト（配列）の要素
- `[main]` のような角括弧の書き方もリストで、`- main` と同じ意味
- `#` 以降はコメント
- `run: |` の `|` は「以降のインデントされた複数行を、改行を保ったまま1つの文字列として扱う」という意味

## GitHub Actions

- [GitHub Actions入門](https://zenn.dev/praha/articles/9e561bdaac1d23)

GitHubが提供する、スクリプトの動作サービス

```PlainText
📁.github/
└─ 📁workflows/
   └─ 📄hoge.yml
```

GitHubリポジトリ上で、上記のようなディレクトリ構成にした場合に、`hoge.yml` がワークフローとして認識される

`.github/workflows/` 内の `.yml` / `.yaml` は**すべて**ワークフロー扱いになる

ファイルを置いただけで実行されるわけではなく、`on:` に書いたトリガーが発生したときに実行される

### 書き方

`hoge.yml` の例

```yaml
name: GitHub Actions Demo

on: [push]

jobs:
  echo_hello_world:
    runs-on: ubuntu-latest
    steps:
      - run: echo "hello world!"
```

pushされた時に `echo "hello world!"` を実行するという内容

`echo "hello world!"` の部分は、コマンドであれば基本的になんでも記述できる

```yaml
jobs:
  echo_hello:
    runs-on: ubuntu-latest
    steps:
      - name: "挨拶"
        run: echo "Nice to meet you!"
      - name: "名前を言う"
        run: echo "My Name is Taro!"
      - name: "趣味を話す"
        run: echo "I love programming!"
```

`steps` 内に書く1つ1つの要素のことを**ステップ**という（1ステップ = 1コマンド + 名前）

#### ワークフロー

YAMLファイル = 1つのワークフロー

#### ジョブ

複数のコマンドをまとめた単位

```yaml
jobs:
  echo_hello:
    runs-on: ubuntu-latest
    steps: 
      - name: "挨拶"
        run: echo "Nice to meet you!!"

      - name: "名前を言う"
        run: echo "My Name is Taro!!"

      - name: "趣味を話す"
        run: echo "I love programming!!"

  echo_goodbye:
    runs-on: ubuntu-latest
    steps: 
      - name: "別れの挨拶をする"
        run: echo "Good Bye!!"
```

ジョブは複数定義することができ、**ジョブの中のステップは直列で実行されるが、それぞれのジョブは並列で実行される**（ワークフローも同様）

ジョブに順番を付けたい場合は `needs: ジョブ名` を書くと「指定したジョブが終わってから実行」にできる

#### トリガー

- [Workflow syntax for GitHub Actions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)

「どういうタイミングで実行するか」

| 記述 | タイミング |
| --- | --- |
| `schedule` | 定期実行 |
| `pull_request` | プルリクエスト作成時 |
| `workflow_dispatch` | 手動実行 |
| `push` | pushされた時 |

`branches` や `paths` はトリガーではなく、トリガーの**絞り込み条件（フィルター）**

- `branches`：どのブランチへのpushで動かすか
- `paths`：どのファイルが変わったら動かすか

両方書いた場合は**両方の条件を満たしたとき**に実行される

#### アクション

「誰かが作った処理をそのままワークフローの一部として使う」機能

- `actions/checkout`
- `actions/setup-node`

といった特定の処理をそのまま利用することができ、`uses: アクション名@バージョン` という形で使用できる

`actions/checkout@v5` の `@v5` は使うアクションのバージョン（タグ）

### `sync-wiki.yml` を解剖してみる

```yaml
name: Sync notes to Wiki
```

単純にワークフローの名前

```yaml
on:
  push:
    branches: [main]
    paths:
      - "notes/**"
      - ".github/scripts/sync-wiki.sh"
      - ".github/workflows/sync-wiki.yml"
  workflow_dispatch:
```

- `main` ブランチにpushされ、かつ `notes/` 配下, `.github/scripts/sync-wiki.sh`, `.github/workflows/sync-wiki.yml` のどれかに変更があった場合に実行される
- このワークフローは手動実行もできる

```yaml
permissions:
  contents: write
```

- リポジトリの内容（コード・Wiki）の**読み書き**を許可する（`write` は読み取りも含む）
- `permissions` を書くと、書かなかった権限（Issue、PRなど）はすべて**権限なし**になる
- 必要な権限だけを与える「最小権限の原則」に沿った書き方

```yaml
concurrency:
  group: sync-wiki
  cancel-in-progress: false
```

- `concurrency`（同時実行制御）：「同じワークフローがほぼ同時に複数回実行されたときの順番整理」を決める
- `group`（グループ分けの名前）：同じグループ名を持つ実行は同時に1つしか動かないというルールで制限できる
- `cancel-in-progress`（実行中のものをキャンセルするか）：同じグループの新しい実行が来たときに「進行中の実行をキャンセルするか」を指定する
- トップレベルに書いているので、制御対象は**ワークフローの実行全体**（各ジョブの中に書けばジョブ単位になる）
- `false` の場合、後から来た実行は待機するが、待機できるのは**1件だけ**（さらに新しい実行が来ると古い待機分はキャンセルされる）
- 「最新の `notes/` をWikiに反映できればよい」ので、この挙動で問題ない

```yaml
jobs:
  sync:
```

- ジョブの名前を `sync` と定義

```yaml
    runs-on: ubuntu-latest
```

- GitHubが用意している**最新の安定版Ubuntu環境**でジョブを実行する
- Ubuntu自体の最新リリースとは限らない（環境を固定したい場合は `ubuntu-24.04` のように明示する）

```yaml
    steps:
```

```yaml
      - name: Checkout repository
        uses: actions/checkout@v5
```

- このリポジトリをチェックアウトする

```yaml
      - name: Checkout wiki
        uses: actions/checkout@v5
        with:
          repository: ${{ github.repository }}.wiki
          path: wiki
```

- Wiki用リポジトリを `wiki/` フォルダにチェックアウトする（`with:` はアクションに渡す引数）
- GitHub Wikiの実体は `リポジトリ名.wiki` という別のGitリポジトリ
- `${{ github.repository }}` はGitHub Actionsの**式**で、実行時に `ユーザー名/リポジトリ名` が埋め込まれる
- **Wikiに1ページもないとこのリポジトリが存在せず失敗する**ので、初回はブラウザからWikiページを1つ作っておく

```yaml
      - name: Copy notes into wiki
        run: bash .github/scripts/sync-wiki.sh notes wiki
```

- 自動同期スクリプト (`sync-wiki.sh`) を動作させる

`sync-wiki.sh` がやっていること

- Wiki側の `.md` をいったん全削除してから `notes/*.md` をコピーする（`notes/` で削除・リネームしたノートがWikiに残らないように）
- 各ノートの最初の `# 見出し` を使って、サイドバー（`_Sidebar.md`）にノート一覧を自動生成する
- `notes/Home.md` がなければ、Wikiのトップページ（`Home.md`）も自動生成する
- **Wikiをブラウザから直接編集しても次の同期で上書きされる**ので、編集は必ず `notes/` で行う

```yaml
      - name: Commit and push wiki
        working-directory: wiki
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add -A
          if git diff --cached --quiet; then
            echo "No changes"
            exit 0
          fi
          git commit -m "Sync notes from ${GITHUB_SHA::7}"
          git push
```

- GitHub Wikiのリポジトリにcommit・pushを行う
- `working-directory: wiki` で、このステップのコマンドは `wiki/` フォルダ内で実行される
- `41898282+github-actions[bot]@...` は、GitHub公式のbotとしてコミットするためのメールアドレス（数字はbotのユーザーID）
- `git diff --cached --quiet` は、ステージした変更が**ない**と成功を返すので「変更なしなら `No changes` で正常終了」という分岐になる（変更なしでcommitするとエラーになるのを避ける）
- `${GITHUB_SHA::7}` はbashの**変数展開**で、コミットIDの先頭7文字を取り出している（`${{ }}` とは別物）
