# dotagents

複数マシン・複数プロジェクトで再利用する、Claude Code と Codex 向けの設定資材を集約したリポジトリ。`CLAUDE.md`・`AGENTS.md` のテンプレート、ルール、エージェント定義、スキル、カスタムコマンドを含む。

**想定読者**: 複数マシン・複数プロジェクトで作業する自分自身（将来の自分）。他の人と共有する場合も、以下の運用方針・使い方を前提に読んでもらえば迷わないはず。

## 運用方針

このリポジトリは **clone してから必要な内容だけをつまみ食いする** ことを想定している。symlink 等による自動同期は行わない。

**`CLAUDE.md` と `rules/` は、対象プロジェクトのセッションで Claude に取り込ませる前提で書いている**（人がファイルをコピーして終わり、ではない。2026-10-21 ユーザー承認）。

1. このリポジトリを clone する
2. 対象プロジェクトのセッションで、使いたいファイルを取り込むよう Claude に頼む。clone した場所を絶対パスで伝え、どのファイルをどこへ取り込むかも伝える（取り込み方の選び方は下記）

   頼み方の例:
   ```
   <clone した場所>/CLAUDE.md を、取り込み先のリポジトリの CLAUDE.md に組み込んで。取り込み先にある固有の記述（技術スタック・コマンドなど）は残して
   ```
3. 取り込んだ内容をプロジェクトの実情に合わせて調整する（プレースホルダーのコマンド例・技術スタックの記述などを実際の内容に書き換える）

- **取り込み方は、配布先ごとに 3 つから選ぶ。** そのまま写す（配布先に同じ資材が無く、中身をそのまま使えるとき）・配布先の `CLAUDE.md` へ組み込む（配布先に `CLAUDE.md` が既にあり、固有の記述を残すとき）・配布先の実情へ読み替える（ワークツリーを使わない、既定ブランチが `master` など、運用が違うとき。読み替えた点は配布先の `CLAUDE.md` に書いておく）
- **資材どうしの参照が配布先で解決しないことは、欠陥として扱わない。** `CLAUDE.md` から `rules/common/*.md` への参照のようなものは、詳細の在り処を示す補足で、規定の中身は参照している行そのものにある。取り込むときに Claude が読み替えるか読み飛ばす
- **自己完結させるか参照先へ任せるかで迷ったら、それが定義か補足かで決める。** 定義（例: 問いに並べる選択肢の中身。参照先にしか無いと、何を出せばよいか決まらない）は参照元にも置く。補足は参照先へ任せてよい
- **本文の「（YYYY-MM-DD ユーザー承認）」や「この設定集の持ち主が決めたこと」は、この設定集の持ち主の判断の記録。** 取り込む側の人が承認したことにはならず、日付の会話記録も取り込み先からは辿れない。従うか、外す・書き換えるかは取り込む側で決め、取り込み先で改めて承認したなら、その日付に置き換える

### 配布先から書き戻す

取り込んだ後にこのリポジトリと同期を取り続ける仕組みは無いため、配布先で良い変更が育ったらこのリポジトリ側にも書き戻しておくと、次に取り込むときに活かせる。配布先での作業中に気づいた教訓は、その場では書き戻し候補としてタスクへ積み、配布先の資材にも控えるだけにする（[rules/common/work-memory.md](./rules/common/work-memory.md)「他のリポジトリにも効く教訓に気づいたとき」）。

書き戻すときは、次の 2 つを読む（2026-10-21 ユーザー承認）。

1. 配布先の資材（`CLAUDE.md`・`rules/` など）と、このリポジトリとの差分。配布先の Claude が控えた書き戻し候補も含む。置き場所は配布先の決まりに従い、決まりが無ければ**配布先の** `.claude/writeback/`（候補 1 件ごとに 1 ファイル。控えるときに配布先の Claude が作る）。以前の既定だった、配布先の `CLAUDE.md` 末尾の「配布元へ書き戻す候補」の節があれば、それも読む
2. 各配布先のメモリ（`~/.claude/projects/<配布先のパスをハイフンで繋いだ名前>/memory/`）。配布先の Claude が、手順や判断基準をメモリへ書いてしまっていることがある。メモリは端末ごとに閉じているので、そこにある手順は他の端末にもこのリポジトリにも届かない。資材へ移すべき手順が残っていないかを見る

**取り込んだ候補は、配布元（このリポジトリ）の台帳 `writeback-imported/` に、配布先の名前を書かずにハッシュで記録する**（2026-10-21 ユーザー承認）。配布先の候補のファイルは消さない。ハッシュにするのは、配布元を公開しても、非公開の配布先のリポジトリ名が台帳から直接読めないようにするため。

手順は [`scripts/writeback-ledger.sh`](./scripts/writeback-ledger.sh) にまとめてある（bash で、Windows では Git Bash で、このリポジトリのトップレベルから実行する）。キーと中身のハッシュの作り方は台本の冒頭にある。**同じことを手で組まない** —— remote の URL や候補のパスの書き方の揺れ、改行の違いで、黙って別のキーになる。

1. `bash scripts/writeback-ledger.sh key <配布先の clone のパス> <候補のパス>` でキーと中身のハッシュを出す。候補のパスは配布先のルートからの相対パス（例: `.claude/writeback/2026-10-21-xxx.md`）
2. `bash scripts/writeback-ledger.sh check <キー> <中身のハッシュ>` で台帳を読む
3. 取り込んだら `record`（台帳が無いとき）か `update`（`CHANGED` だったとき）に `<キー> <中身のハッシュ> "<取り込んだ先のファイルと節>"` を渡して台帳を書き、書き戻しと同じコミットに入れる。取り込んだ先の説明に、配布先の名前を書かない

| 出力の先頭語 | 意味と、すること |
|---|---|
| `KEY` / `CONTENT` | `key` の結果。この 2 つの値を `check` と `record` / `update` にそのまま渡す |
| `IMPORTED` | 取り込み済みで、中身も同じ。飛ばす |
| `CHANGED` | 取り込み済みだが、取り込んだ後に書き換えられた。読み直し、取り込んだら `update`。括弧の中の ref がいまのブランチに入っていなければ（別の `ready/*` か、いまのブランチより新しい既定ブランチにある）、先にそのブランチを取り込んでから（既定ブランチなら `git merge <既定ブランチ>`）`update` する |
| `NOT-FOUND` | 台帳に無い。読み、取り込んだら `record` |
| `RECORDED` / `UPDATED` | 台帳を書いた（コミットはまだ）。書き戻しと同じコミットに入れる |
| `STOP` | 続けられない。理由は `STOP:` の後ろに出る（`key` なら origin が設定されていない・GitHub の `<持ち主>/<リポジトリ名>` の形でない・候補が既定ブランチに無い など。`check`・`record`・`update` なら値の形が正しくない・台帳の有無が合わない など）。台帳に載せずに止まり、出た理由をユーザーへ伝えて扱いを聞く |

- `check` が見るのは、このリポジトリの既定ブランチと `ready/` で始まるブランチの、**コミット済みの**台帳だけ。`record` した直後（コミット前）や、作業中の `worktree/*` のブランチにある台帳は見えない
- 前の既定の節（配布先の `CLAUDE.md` 末尾）にある候補は、台帳に載せない（候補ごとのファイルが無く、キーを作れないため）。読むたびに、既に入っていないかを候補の題や症状の言葉で検索する。配布先のリポジトリ名や持ち主を変えたときもキーが変わるので、同じく検索で確かめる（[AGENTS.md](./AGENTS.md)「配布先から取り込むとき」）
- **ハッシュは名前を伏せるだけで、強い秘匿ではない。** 台帳から配布先の名前は逆算できないが、配布先の名前と候補のパスを推測した人には、計算すれば「その候補をこのリポジトリへ取り込んだ」ことが分かる

読むものはここが正。書き戻した内容をこのリポジトリへ書くときの決まり（既存の記述との突き合わせ・一般化）は [AGENTS.md](./AGENTS.md)「配布先から取り込むとき」に置いてある。

## ディレクトリ構成

```
dotagents/
  README.md              # このファイル
  CLAUDE.md               # プロジェクトCLAUDE.mdのテンプレート（プレースホルダー入り）
  AGENTS.md               # この設定集を保守するためのCodex指示
  COMPATIBILITY.md         # Claude Code／Codexの互換性一覧
  templates/codex/AGENTS.md # 対象プロジェクトへコピーするCodex用テンプレート
  templates/codex/.codex/agents/ # Codexカスタムエージェントのテンプレート
  templates/codex/.agents/skills/ # Codexワークフロースキルのテンプレート
  templates/codex/.gitignore.additions # 対象リポジトリへマージする除外パターン
  rules/
    common/                # 言語・フレームワークに依存しない汎用ルール（常時読み込み）
    java/                  # Java/Spring Boot向けの補足ルール（commonの内容を前提に差分のみ記載）
    dotnet/                # C#/.NET向けの補足ルール（同上）
    mcp/                   # MCPツール（Context7・Playwright・Serena）の活用ガイド
  agents/
    *.md                   # 汎用的なサブエージェント定義
    java/                  # Java/Spring Boot固有のサブエージェント定義（JavaDoc・Maven・Mockito前提）
  commands/
    *.md                   # カスタムスラッシュコマンド定義
  settings.json            # ~/.claude/settings.json のテンプレート（permissions・model・hooks 等）
  statusline-command.sh    # ステータスライン表示スクリプト（モデル名・コンテキスト使用率・Gitブランチ）
  scripts/
    writeback-ledger.sh    # 配布先の書き戻し候補を取り込み済みか見分ける台帳の台本（「配布先から書き戻す」参照）
    git-hooks/pre-push     # 許可していないメールアドレスでの push を止めるフック（「8. push するメールアドレスを縛る場合」参照）
  writeback-imported/      # その台帳（取り込んだ候補 1 件ごとに 1 ファイル。最初に取り込んだときにできる）
  .gitignore               # 機密・実行時データの混入を防ぐ除外パターン
  .gitattributes           # 台本とフック（scripts/*.sh・scripts/git-hooks/*）をどの端末でも LF で取り出す設定
  skills/
    */                     # スキル定義一式（大半は外部スキル集からの複製。下記「skills/ について」参照）
  .agents/skills/
    agent-config-maintenance/  # この設定集を保守するためのCodexスキル
```

### 対応ランタイム

| 資材 | Claude Code | Codex |
|------|-------------|-------|
| `CLAUDE.md` | プロジェクト指示 | 移植が必要 |
| `AGENTS.md` | — | この設定集を保守する指示 |
| `templates/codex/AGENTS.md` | — | 対象プロジェクトへコピーするテンプレート |
| `templates/codex/.codex/agents/` | — | 対象リポジトリ用のカスタムエージェント |
| `templates/codex/.agents/skills/` | — | 対象リポジトリ用の検証済みワークフロースキル |
| `templates/codex/.gitignore.additions` | — | Codex作業用の一時出力を除外する追記候補 |
| `rules/` | `.claude/rules/` へ取り込む | 原則は参照用。個別に移植が必要 |
| `agents/`, `commands/`, `settings.json` | Claude Code向け定義・設定 | 非互換 |
| `skills/` | `.claude/skills/` へコピー（スキルはファイルのまま動くので、写して置く） | 一括コピー不可。個別の移植・検証が必要 |
| `.agents/skills/` | — | この設定集を保守するCodex用スキル |

同じ目的のファイルでもランタイムごとに形式や読み込み方が異なる。導入前に必ず [COMPATIBILITY.md](./COMPATIBILITY.md) で分類を確認すること。

### `CLAUDE.md` と `rules/common/` の重複について

**同じ規約が両方に存在するのは意図的**（配布形態が 2 通りあるため）。`CLAUDE.md` だけを取り込む配布先と、`rules/common/` をモジュールとして使う配布先の両方で成立させる必要がある。

**ただし両方を手で書き分けると、意味の同じ箇所が独立に編集されて必ずずれる。** 文面を変えるときは **`rules/common/` 側を先に直し、`CLAUDE.md` 側はその変換結果にする**。変換は 4 つ。

1. **見出しを 1 段下げる**（`## X` → `### X`、`### X` → `#### X`）
2. **段落の折り返しを畳む**（日本語なので連結に空白を入れない。表と箇条書きは畳まない）
3. **他ファイルへの相対リンクを置き換える。** `CLAUDE.md` は**単体でプロジェクトへ取り込まれる**ため、`rules/` 配下を指す相対リンクは配布先で解決しない。`CLAUDE.md` 側に同等の節があれば「下記「…」」へ、無ければバッククォートのフルパス（`` `rules/common/code-review.md` ``）へ書き換える
4. **この README を指す記述は落とす。** 配布先には届かないため

**複製の単位は節で、ファイルではない。** `CLAUDE.md` は `rules/common/` を写したものではなく、**単体で取り込む配布先にも効かせたい節だけ**を持つ（対応する節を 1 つも持たないファイルもあれば、`performance.md`・`worktree.md` のように一部の節だけを複製しているファイルもある）。**新しい節は `rules/common/` 側へ先に書き、単体配布でも効かせたいものだけを `CLAUDE.md` へ複製する。** 複製しない節は、`rules/common/` を取り込む配布先にだけ届く。

### `rules/common/` と言語別ルールの関係

`rules/java/` `rules/dotnet/` 配下のファイルは、同名の `rules/common/` ファイルを前提とした**差分**として書かれている。例えば `rules/java/testing.md` は `rules/common/testing.md` の汎用的な TDD ワークフローやエッジケースの考え方を前提に、JUnit 5 / Mockito の具体的な書き方だけを補足する。`rules/dotnet/testing.md` は同じ位置づけで xUnit の書き方を補足する。他言語向けの補足ルール（`rules/python/` 等）を増やす場合も同じ構成パターンに従う。

#### 言語別ルールは frontmatter で読み込みを絞る（重要）

言語別ルールの各ファイル先頭には、対象ファイルを限定する YAML frontmatter が入っている:

```yaml
---
paths:
  - "**/*.cs"
  - "**/*.csproj"
---
```

これにより、C# を触っているセッションでは `rules/dotnet/` だけが読み込まれ、`rules/java/` の Maven や JPA の話は流れ込まない。**frontmatter を外すと全プロジェクトで常時読み込まれ、無関係な言語のルールがコンテキストを圧迫する**ので、コピー時・追記時に消さないこと。`rules/common/` と `rules/mcp/` は逆に、言語を問わず常時読み込ませたいので frontmatter を付けない。

### `agents/` と `agents/java/` の関係

`agents/` 配下は言語・フレームワークを問わず使えるように framing を汎用化したエージェント定義。`agents/java/` 配下の3ファイル（`reviewer.md`, `java-reviewer.md`, `java-build-resolver.md`）は JavaDoc・Maven・Mockito 前提の内容が本質的に Java/Spring Boot 固有のため、汎用化せずそのまま Java 向けとして残している。Java プロジェクトでは `agents/` の該当ファイルと `agents/java/` の3ファイルを両方コピーする。

### `skills/` について

`skills/` 配下の大半（`gateguard`, `springboot-patterns`, `security-review` 等）は自作ではなく**外部のスキル集から複製したもの**。再入手可能な内容だが、環境を移す際に毎回同じスキル集を探し直す手間を省くためバックアップとして含めている。以下の4個だけは事情が異なるので個別に注意する:

**このディレクトリはCodex用の一括コピー元ではない。** Claude Codeのツール・フック・パスを前提にする資材を含むため、Codexへ置けるのは [COMPATIBILITY.md](./COMPATIBILITY.md) で検証済みと明記されたもの、または個別に移植・検証したものだけ。

- **`release`**: 自作。**単体では機能しない**（完了ブランチを `ready/*` へ改名する規約が前提のため）。導入経路によって必要な組み合わせが変わる:
  - `CLAUDE.md` テンプレートを使う場合 — `CLAUDE.md`（「リリース」節に規約を内包）＋ このスキル
  - `rules/common/` をモジュールとして使う場合 — `worktree.md`（`ready/` 規約）＋ `development-workflow.md`（手順9〜10）＋ `git-workflow.md`（マージ・版上げの委譲先）＋ `security.md`（push 前の個人情報の確認）＋ このスキル
  - 両方使う場合は上記すべて

  コピー後に置き換えるべきもの（既定ブランチ名・各種コマンド・検証手段）は SKILL.md 冒頭の「コピー時に置き換えるもの」に列挙してある
- **`review`**: Java専門のコードレビューチェックリスト。自作で、`agents/java/reviewer.md` と観点が重複している
- **`continuous-learning-v2`**: セッションを観測して再利用可能なパターンを自動抽出する自律学習システム。`hooks/observe.sh` を `PreToolUse`/`PostToolUse` フックとして `settings.json` に登録しないと動作しない（スキルフォルダをコピーするだけでは有効化されない）
- **`learned/`**: `/learn` コマンドの出力先。中身は都度生成されるものなので空のままでよい。git は空ディレクトリを追跡しないため `.gitkeep` を置いてフォルダだけ再現されるようにしている

## 使い方

### 0. Codex で使う場合

対象プロジェクトのルートへ `templates/codex/AGENTS.md` を `AGENTS.md` としてコピーし、`templates/codex/.codex/agents/` と `templates/codex/.agents/skills/` も同じ相対パスへコピーする。`templates/codex/.gitignore.additions` から使う一時出力パスだけを既存の `.gitignore` にマージし、プレースホルダーを対象プロジェクトの実情で置き換える。リポジトリ直下の `AGENTS.md` はこの設定集を保守するためのものなので、コピーしない。Codex は起動時に、リポジトリルートから作業ディレクトリまでにある `AGENTS.md` を読み込み、より近いディレクトリの指示を優先する。

このリポジトリの `rules/` はCodexに自動読み込みされない。内容を使う場合は、[COMPATIBILITY.md](./COMPATIBILITY.md) の「移植が必要な資材」に従って、Claude固有のツール名・パス・フックを除去または置き換える。長大なルールを無批判に一枚へ詰め込まず、対象作業に必要なものだけを残す。

Codex用のスキルは、`templates/codex/.agents/skills/` にある検証済みのものだけを対象プロジェクトの `.agents/skills/<skill-name>/` へ置く。`development-workflow`、`code-review`、`release`、`capture-learning`、`worktree-workflow` を用意している。`skills/` の内容をそのままコピーしてはいけない。

`~/.codex/config.toml` は個人環境の設定であり、このリポジトリのファイルで上書きしない。共有すべき規約は `AGENTS.md`、共有すべき再利用手順は `.agents/skills/` に置く。

### Codexインポート結果を取り込む場合

他のリポジトリでCodexのインポート機能が生成した `AGENTS.md` は、対象プロジェクトの仕様・コマンド・ローカルパスを含む一次資料として扱う。この設定集へ丸ごとコピーせず、複数プロジェクトで意味が変わらない規約だけをテンプレートまたはスキルへ移植する。`EnterWorktree`、`ExitWorktree`、`TaskCreate`、`AskUserQuestion` のように利用可否や形式を保証できないツール名、Claude由来のパス・フック、固定のモデル名は取り除くか、GitとCodexの文書化済み機能へ書き換える。

取り込んである主な共通規約は、合意済みの範囲を勝手に縮小しないこと、機能削除前に実利用を調査すること、ビルドだけでなく適切な動作確認を行うこと、レビューが収束しないときは直し方ではなく設計を疑い、範囲を超えるなら相談か切り出しで区切ること、提案に根拠を添え設計として正しい案を推すこと、ユーザーが決めていないことを決まったことにしないこと、利用者向けの文言を実装前に諮ること、公開リポジトリで個人情報を出さないこと、ユーザーに見せる文を日本語で書くこと。プロジェクト固有のビルド・デプロイ・API・UI仕様は、それぞれのプロジェクトの `AGENTS.md` に残す。

### 1. CLAUDE.md を取り込む場合

配布先に `CLAUDE.md` が既にあるなら、上記「運用方針」の「組み込む」で取り込む。

`CLAUDE.md` をプロジェクトルートの `CLAUDE.md` へ取り込むよう Claude に頼み、末尾の「プロジェクト固有の設定」セクションに技術スタック・補助コマンド・構成メモを書き込む。それ以外のセクション（変更時の基本フロー・検証・敵対的レビュー・ドキュメント更新等）はそのまま使える想定だが、プロジェクトの運用と食い違う箇所があれば調整する。

**変更時の基本フローを使うなら、次のファイルも一緒に取り込む。** 欠けると、それを使う手順（レビュー・リリース）が実行できない。

- `release` スキル（`skills/release/` を `.claude/skills/release/` へ）。SKILL.md 冒頭の「コピー時に置き換えるもの」（既定ブランチ名・`node` と `claude` CLI など）も確かめる。詳しくは上記「`skills/` について」
- レビューのエージェント定義（`agents/` の `adversarial-reviewer`・`silent-failure-hunter`・`meta-reviewer`・`doc-objectivity-reviewer`・`code-explorer` を `.claude/agents/` へ）。小さな変更なら `adversarial-reviewer`（文書も直すなら `doc-objectivity-reviewer` も）だけで回る
- `.gitignore` に `.claude/worktrees/` と `.claude/release.lock` を足す（作業用のワークツリーとロックを、コミットに混ぜないため）

フローの一部だけを使う配布先は、使わない手順を配布先の `CLAUDE.md` に書いておく（上記「運用方針」の「読み替える」）。

### 2. Claude Codeでrulesを取り込む場合

必要なファイルだけを対象プロジェクトの `.claude/rules/common/`（または `rules/java/`, `rules/dotnet/`, `rules/mcp/`）へ取り込むよう Claude に頼む。ファイル同士が相対リンクで参照し合っている点に注意する:

- `rules/common/` 内は同階層への参照（例: `[worktree.md](./worktree.md)`）
- `rules/java/` `rules/dotnet/` の各ファイルは対応する `rules/common/` ファイルへの上位階層参照（例: `[testing.md](../common/testing.md)`）を前提にした**差分**として書かれているため、言語別ルールだけを取り込む場合は対応する `rules/common/` ファイルも必ず一緒に取り込む

次の 4 つは単独で効く規約で、他のファイルからのリンクを辿るだけでは見落としやすい（`communication.md` はどこからもリンクされていない）。つまみ食いするときに取りこぼさないこと。

- `communication.md` — ユーザーに見せる文の言語
- `proposals.md` — 提案の出し方と、ユーザーの答えの扱い
- `security.md` — 公開リポジトリで個人情報を出さないための決まり
- `command-execution.md` — コマンドの成否の判定と、環境ごとの落とし穴

取り込んだ後は次の2点を確認する:

1. リンク先が対象プロジェクトの `.claude/rules/` 配下に実在すること
2. 言語別ルールの frontmatter（`paths:`）が残っていること。消えていると無関係な言語のルールが常時読み込まれる（上記「言語別ルールは frontmatter で読み込みを絞る」参照）

### 3. Claude Codeでagentsをコピーする場合

使いたいエージェントだけを対象プロジェクトの `.claude/agents/` にコピーする。`.claude/rules/common/agents.md`（エージェントオーケストレーションルール）と組み合わせて使うと、どのタイミングでどのエージェントを呼ぶかの指針が揃う。

### 4. Claude Codeでcommandsをコピーする場合

使いたいコマンドだけを対象プロジェクトの `.claude/commands/`（プロジェクト単位で使う場合）または `~/.claude/commands/`（全プロジェクト共通で使う場合）にコピーする。コピーすると `/learn` のようにスラッシュコマンドとして呼び出せるようになる。

### 5. Claude Codeでsettings.jsonを使う場合

`~/.claude/settings.json`（全プロジェクト共通の設定）のテンプレート。**そのまま上書きコピーせず、必要な項目だけを既存の設定にマージする**（上書きすると既存の許可設定や個人設定が消える）。

収録内容:

| 項目 | 内容 |
|------|------|
| `env` | 環境変数。`CLAUDE_CODE_ENABLE_TODO_TOOLS` はタスク機能（`TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate`）を有効にする。モデルやバージョンによっては既定で配られないため、使う場合は明示する。反映にはアプリの再起動が要る |
| `permissions.allow` | よく使う読み取り系コマンド・Git 操作・MCP ツール（Playwright・Context7・Serena 等）を確認プロンプト無しで許可するパターン集 |
| `permissions.ask` | `git push --force` 系は明示的に確認を求める（履歴を壊しうるため、`allow` には入れていない） |
| `model` / `language` / `effortLevel` / `tui` 等 | 個人の好みの設定。**そのまま使う前に自分の好みに合わせて調整すること** |
| `statusLine` | `statusline-command.sh` の登録。下記「7. statusline-command.sh を使う場合」を先に実施しないと動作しない |
| `hooks` | `skills/continuous-learning-v2/hooks/observe.sh` の登録。**このスキルを `~/.claude/skills/` にコピーしていないとフックが毎回失敗する** |

`env` は既存の設定に**キー単位でマージする**こと。オブジェクトごと置き換えると、そこにあった他の環境変数が消える。

`CLAUDE_CODE_ENABLE_TODO_TOOLS` は変数名が `TODO` だが、有効になるのは `Task` 系のツールで `TodoWrite` ではない。また**公式ドキュメントに記載が無い設定**のため、将来の更新で効かなくなる可能性がある。タスク機能が急に使えなくなったら、まずここを疑うこと。

`statusLine` と `hooks` のコマンドパスは `~/.claude/...` 起点で書いてある。別の場所に置く場合は書き換えること。

### 6. Claude Codeでskillsをコピーする場合

使いたいスキルだけを対象プロジェクトの `.claude/skills/`（プロジェクト単位）または `~/.claude/skills/`（全プロジェクト共通）にコピーする。`continuous-learning-v2` を有効化する場合は、対応する `hooks` 設定（`settings.json` の該当セクション）も一緒に用意する必要がある。

### 7. Claude Codeでstatusline-command.shを使う場合

ステータスラインにモデル名・思考の深さ（effort）・コンテキスト使用率（残量に応じて緑／黄／赤）・Git ブランチ名（未コミット変更があれば `*`）を表示するスクリプト。

1. `~/.claude/statusline-command.sh` にコピーする
2. 実行権限を付ける: `chmod +x ~/.claude/statusline-command.sh`
3. `~/.claude/settings.json` に登録する:
   ```json
   "statusLine": { "type": "command", "command": "~/.claude/statusline-command.sh" }
   ```

`bash` と `python3`（JSON パースに使用）が PATH 上にあることが前提。

### 8. push するメールアドレスを縛る場合

`scripts/git-hooks/pre-push` は、許可したアドレス以外を author・committer に持つコミットの push を止める。公開リポジトリへ勤務先や個人のアドレスを載せてしまう事故を防ぐためのもの。判定は許可リスト方式で、1 つも設定されていなければ push を止める。

配布元のルートで、この順に行う。

1. 許可するアドレスを並べる（パターンはシェルのグロブ）。**先にこれを入れる** —— 2・3 だけ済ませると、許可リストが空の間は全リポジトリの push が止まる:
   ```bash
   git config --global --add hooks.allowedAuthorEmail '*+<GitHub のユーザー名>@users.noreply.github.com'
   git config --global --add hooks.allowedAuthorEmail 'noreply@anthropic.com'
   ```
   1 行目は `数字+ユーザー名@users.noreply.github.com` の形に当たる。`+` の無い古い形のアドレスを使っているなら、それも足す。2 行目は **Claude が author になるコミット**のため（`Co-Authored-By` は本文なので対象外だが、author 欄がこのアドレスになることがある）。
   **パターンに `[...]` を直接書かない。** シェルのグロブでは文字クラスとして読まれる。`41898282+github-actions[bot]@users.noreply.github.com` を許すなら `*github-actions*@users.noreply.github.com`（`github-actions` を含む別のアカウントも通る。厳密にするなら `[` を逃がす）。
2. 置いて実行権を付ける:
   ```bash
   mkdir -p ~/.git-hooks && cp scripts/git-hooks/pre-push ~/.git-hooks/ && chmod +x ~/.git-hooks/pre-push
   ```
3. 全リポジトリで使うよう登録する（既に `core.hooksPath` を別の場所へ設定しているなら、**上書きせず**その置き場へ手順 2 で置く）:
   ```bash
   git config --global core.hooksPath "$HOME/.git-hooks"
   ```
   **`core.hooksPath` を設定すると、各リポジトリの `.git/hooks/` は読まれなくなる。** 置き換わるだけで連鎖しないので、リポジトリ固有の検査が黙って死ぬ（このフックは `pre-push` に限り、自分で呼び直す）。逆に、リポジトリ側が `core.hooksPath` を持っている（husky 等）と、グローバルのフックのほうが動かない。

#### 勤務先など、公開しないリポジトリ

手順 3 で全リポジトリに効くので、勤務先のリポジトリへ push すると勤務先のアドレスが引っかかる。**そのリポジトリでだけ許す。**

```bash
git config --local --add hooks.allowedAuthorEmail '<勤務先のアドレス>'
```

**グローバルへ足して済ませないこと。** 全リポジトリで通るようになり、公開側の歯止めが外れる。

**公開リモートも持つリポジトリでは使わない。** この設定はリポジトリ単位なので、そのリポジトリが持つ**すべての** remote に効く。社内と公開のミラーを両方持つなら、`git config --local user.email` を noreply 形式にして、勤務先のアドレスで commit しないようにする。

**push 先によって検査を切り替える仕組みは、意図して持っていない**（2026-10-23 ユーザー承認）。切り替えるには push 先 URL からホストを判定することになるが、URL の形（スキームの有無・scp 形式・`#` や `?` の扱い）は解釈が割れ、取り違えると公開側が素通りする。上の `--local` なら、**書き忘れても push が止まるだけ**で済む（止まった先で 1 行足せばよい）。その代わり公開リモートも持つリポジトリでは使えず、そこは直前のとおり `user.email` のほうを分ける。

#### このフックで止まらないもの

- **フックを入れていない端末からの push。** フックは git の管理外なので、clone しても付いてこない。端末ごとに手順 1〜3 が要る。配布元のフックを直したら、入れた端末それぞれで手順 2 をやり直す
- **リポジトリ側が `core.hooksPath` を持っている場合**（husky 等）。そちらが優先されるので、**その置き場へこのフックも置かない限り動かない**
- **`--no-verify` を付けた push。** git の仕様で、フックからは防げない
- **GitHub の Web 画面での編集、CI が自分で行う push。** 手元を通らない
- **注釈付きタグの作成者・タグのメッセージ・コミットメッセージ本文（`Co-Authored-By` 等）・ブランチ名とタグ名。** 見ているのはコミットの author と committer だけ

上の 2 つは設置で塞げる。残りは機械では止まらないので、目で確かめる。何を機械で止め、何を目で見るかの原則は [`rules/common/security.md`](rules/common/security.md)「公開する前に個人情報が無いことを確かめる」にある。

## 注意事項

- 各ファイルはコピー元プロジェクト（Java/Spring MVC ベースのレガシー端末エミュレータ）から汎用化・言語固有部分の切り出しを行ったもの。汎用化の過程で見落としがあれば、使用時に気づいた範囲で直接修正してよい
- 社内固有の情報（ホスト名・チケット番号・個人のメモリキー参照等）は含まれない想定。コピー先プロジェクトの固有情報は各プロジェクト側で追記すること
- **このリポジトリは公開されている**。認証情報（`.credentials.json`）・会話履歴（`history.jsonl`）・組織のポリシー設定（`remote-settings.json` 等）・セッションデータは絶対にコミットしない。`.gitignore` に歯止めを入れてあるが、新しくファイルを追加するときは中身を必ず確認すること
- 個人のペルソナ設定（`~/.claude/CLAUDE.md` のキャラクター設定・`personas/`・`hooks/random-persona.sh`）は意図的に含めていない。必要なら各自の環境で用意すること
