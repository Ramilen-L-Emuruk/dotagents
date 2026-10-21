#!/usr/bin/env bash
# 配布先の書き戻し候補を、配布元の台帳 writeback-imported/<キー> で見分けるための台本。
# bash で動かす（Windows では Git Bash）。PowerShell からは呼ばない（パイプの文字コードと末尾の改行でキーが変わる）。
#
# キー     : 配布先の origin を <持ち主>/<リポジトリ名> の小文字に揃え（https・ssh・scp の形、ユーザー情報、
#            ポート、www.、末尾の / と .git の違いを消す）、"/<候補のパス>" をつないだ文字列の git hash-object。
#            候補のパスは配布先のルートからの相対パスで、先頭の ./ と \ 区切りと連続した / を揃えてから使う。
# 中身     : 配布先の既定ブランチにある候補の版を、改行を LF に揃えてから git hash-object したもの。
# 台帳     : writeback-imported/<キー>。1 行目に中身のハッシュ、2 行目に日付と取り込んだ先。配布先の名前は書かない。
#
#   key    <配布先のリポジトリのパス> <候補のパス>   → "KEY <キー>" と "CONTENT <中身のハッシュ>"
#   check  <キー> <中身のハッシュ>                   → "IMPORTED (<ref>)" / "CHANGED (<ref>)" / "NOT-FOUND"
#          配布元（このリポジトリ）の既定ブランチと ready/ で始まるブランチのコミット済みの台帳だけを見る
#   record <キー> <中身のハッシュ> <取り込んだ先>    → "RECORDED writeback-imported/<キー>"（台帳が無いときだけ）
#   update <キー> <中身のハッシュ> <取り込んだ先>    → "UPDATED writeback-imported/<キー>"（台帳があるときだけ）
#
# どれも、続けられないときは "STOP: <理由>" を出して終了コード 1 で止まる。判定は標準出力の先頭語で行う。
# それぞれの出力のあとにすることは、README.md「配布先から書き戻す」の表が持つ。
set -u

stop() { echo "STOP: $*"; exit 1; }

source_top() {
  # 配布元のトップレベル。いまいるフォルダではなく、台本の置き場所から決める（配布先のフォルダで流しても配布先に書かない）
  local d
  d=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd) || return 1
  [ -f "$d/scripts/writeback-ledger.sh" ] || return 1
  git -C "$d" rev-parse --show-toplevel 2>/dev/null
}

is_hash() { [[ $1 =~ ^[0-9a-f]{40}$ ]]; }

normalize_remote() {
  # origin の URL を <持ち主>/<リポジトリ名> の小文字へ。GitHub 以外・形が合わないものは空を返す。
  local u="$1" auth host path
  case "$u" in
    *://*)                            # https://, http://, ssh://, git://
      u="${u#*://}"
      auth="${u%%/*}"; path="${u#*/}"
      [ "$auth" != "$u" ] || return 0
      host="${auth##*@}"              # ユーザー情報（user@ / token@）は、ホストの部分の中でだけ外す
      host="${host%%:*}"              # ポートを外す
      ;;
    *@*:*)                            # git@github.com:owner/repo（scp の形）
      auth="${u%%:*}"; path="${u#*:}"
      host="${auth##*@}"
      ;;
    *) return 0 ;;
  esac
  host=$(printf '%s' "$host" | tr 'A-Z' 'a-z'); host="${host#www.}"
  [ "$host" = "github.com" ] || return 0
  path=$(printf '%s' "$path" | tr 'A-Z' 'a-z')
  path="${path%/}"; path="${path%.git}"; path="${path%/}"
  printf '%s' "$path" | grep -Eq '^[a-z0-9._-]+/[a-z0-9._-]+$' || return 0
  printf '%s' "$path"
}

normalize_path() {
  # 候補のパスを揃える（\ を / に、連続した / を 1 つに、先頭の ./ と / を外す）
  local p
  p=$(printf '%s' "$1" | tr '\\' '/' | sed -E 's#/+#/#g; s#^(\./)+##; s#^/##')
  printf '%s' "$p"
}

default_branch() {
  # 既定ブランチの ref を返す（origin/HEAD が無ければ origin/main・origin/master・main・master の順）
  local repo="$1" r
  r=$(git -C "$repo" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null) && { printf '%s' "$r"; return; }
  for r in origin/main origin/master main master; do
    git -C "$repo" rev-parse -q --verify "$r^{commit}" >/dev/null 2>&1 && { printf '%s' "$r"; return; }
  done
}

write_ledger() {
  # $1=record|update $2=キー $3=中身のハッシュ $4=取り込んだ先
  is_hash "$2" || stop "キーが 40 桁の 16 進ではない: $2（key の出力をそのまま渡す）"
  is_hash "$3" || stop "中身のハッシュが 40 桁の 16 進ではない: $3（key の出力をそのまま渡す）"
  [ -n "$4" ] || stop "取り込んだ先が空"
  local top f
  top=$(source_top) || stop "配布元のトップレベルが分からない（台本を配布元の scripts/ に置いたまま呼ぶ）"
  f="$top/writeback-imported/$2"
  if [ "$1" = record ]; then
    [ -e "$f" ] && stop "台帳が既にある: writeback-imported/$2（中身が変わった候補なら update を使う）"
  else
    [ -f "$f" ] || stop "いまのブランチに台帳が無い: writeback-imported/$2（check の CHANGED が別のブランチを指していたら、先にそのブランチを取り込む。初めてなら record を使う）"
  fi
  mkdir -p "$top/writeback-imported" || stop "フォルダを作れない"
  printf '%s\n%s %s\n' "$3" "$(date +%Y-%m-%d)" "$4" > "$f" || stop "書けない: $f"
  if [ "$1" = record ]; then echo "RECORDED writeback-imported/$2"; else echo "UPDATED writeback-imported/$2"; fi
}

cmd="${1:-}"
case "$cmd" in
  key)
    [ $# -eq 3 ] || stop "使い方: key <配布先のリポジトリのパス> <候補のパス>"
    repo="$2"; cand=$(normalize_path "$3")
    [ -n "$cand" ] || stop "候補のパスが空"
    git -C "$repo" rev-parse --git-dir >/dev/null 2>&1 || stop "リポジトリではない: $repo"
    url=$(git -C "$repo" remote get-url origin 2>/dev/null) || stop "origin が設定されていない（台帳に載せず、ユーザーに扱いを聞く）"
    name=$(normalize_remote "$url")
    [ -n "$name" ] || stop "origin が GitHub の <持ち主>/<リポジトリ名> の形にならない（台帳に載せず、ユーザーに扱いを聞く）"
    br=$(default_branch "$repo"); [ -n "$br" ] || stop "既定ブランチが分からない"
    [ "$(git -C "$repo" cat-file -t "$br:$cand" 2>/dev/null)" = blob ] || stop "既定ブランチ（$br）に候補のファイルが無い: $cand（既定ブランチに入ってから読む。入っているはずなら、配布先で git fetch してから流し直す）"
    key=$(printf '%s' "$name/$cand" | git hash-object --stdin) || stop "キーを計算できない"
    content=$(git -C "$repo" show "$br:$cand" | tr -d '\r' | git hash-object --stdin) || stop "中身のハッシュを計算できない"
    is_hash "$key" && is_hash "$content" || stop "ハッシュの形が正しくない"
    echo "KEY $key"
    echo "CONTENT $content"
    ;;
  check)
    [ $# -eq 3 ] || stop "使い方: check <キー> <中身のハッシュ>"
    key="$2"; content="$3"
    is_hash "$key" || stop "キーが 40 桁の 16 進ではない: $key"
    is_hash "$content" || stop "中身のハッシュが 40 桁の 16 進ではない: $content"
    top=$(source_top) || stop "配布元のトップレベルが分からない（台本を配布元の scripts/ に置いたまま呼ぶ）"
    br=$(default_branch "$top"); [ -n "$br" ] || stop "既定ブランチが分からない"
    found=""
    for ref in "$br" "${br#origin/}" $(git -C "$top" for-each-ref --format='%(refname:short)' 'refs/heads/ready/'); do
      git -C "$top" cat-file -e "$ref:writeback-imported/$key" 2>/dev/null || continue
      first=$(git -C "$top" show "$ref:writeback-imported/$key" | head -n 1 | tr -d '\r')
      if [ "$first" = "$content" ]; then echo "IMPORTED ($ref)"; exit 0; fi
      found="$ref"
    done
    if [ -n "$found" ]; then echo "CHANGED ($found)"; else echo "NOT-FOUND"; fi
    ;;
  record|update)
    [ $# -eq 4 ] || stop "使い方: $cmd <キー> <中身のハッシュ> <取り込んだ先>"
    write_ledger "$cmd" "$2" "$3" "$4"
    ;;
  *)
    stop "使い方: key | check | record | update（台本の冒頭の説明を見る）"
    ;;
esac
