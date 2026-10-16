#!/usr/bin/env bash
# notes/ の学習ノートを Wiki リポジトリにミラーする
# 使い方: sync-wiki.sh <notes_dir> <wiki_dir>
set -euo pipefail

notes_dir="$1"
wiki_dir="$2"

# notes/ を正とするため、Wiki 側の .md をいったん全部消してからコピーする
# （notes/ で削除・リネームしたノートが Wiki に残らないように）
find "$wiki_dir" -maxdepth 1 -type f -name '*.md' -delete

shopt -s nullglob
files=("$notes_dir"/*.md)

for f in "${files[@]}"; do
  cp "$f" "$wiki_dir/"
done

# サイドバー（ノート一覧）を生成する
# リンクの表示名はノートの最初の "# 見出し"、なければファイル名
index=""
for f in "${files[@]}"; do
  name=$(basename "$f" .md)
  [[ "$name" == "Home" || "$name" == _* ]] && continue
  title=$(grep -m1 '^# ' "$f" | sed 's/^# //' || true)
  index+="- [[${title:-$name}|${name}]]"$'\n'
done

printf '## 学習ノート\n\n%s' "$index" > "$wiki_dir/_Sidebar.md"

# notes/Home.md がなければトップページも生成する
if [[ ! -f "$notes_dir/Home.md" ]]; then
  printf '# C#学習ノート\n\nこのWikiはリポジトリの `notes/` から自動生成されている\nWikiを直接編集しても次の同期で上書きされるので、編集は `notes/` で行う\n\n%s' "$index" > "$wiki_dir/Home.md"
fi
