# dotagents

複数マシン・複数プロジェクトで再利用する、Claude Code と Codex 向けの設定資材を集約したリポジトリ。`CLAUDE.md`・`AGENTS.md` のテンプレート、ルール、エージェント定義、スキル、カスタムコマンドを含む。

**想定読者**: 複数マシン・複数プロジェクトで作業する自分自身（将来の自分）。他の人と共有する場合も、以下の運用方針・使い方を前提に読んでもらえば迷わないはず。

## 運用方針

このリポジトリは **clone してから必要な内容だけをつまみ食いする** ことを想定している。symlink 等による自動同期は行わない。

1. このリポジトリを clone する
2. 使いたいファイルだけを、対象ランタイムに対応する場所へコピーする
3. コピーしたファイルをプロジェクトの実情に合わせて調整する（プレースホルダーのコマンド例・技術スタックの記述などを実際の内容に書き換える）

コピー後にこのリポジトリと同期を取り続ける仕組みは無いため、良い変更を思いついたらこのリポジトリ側にも書き戻しておくと、次にコピーするときに活かせる。

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
  .gitignore               # 機密・実行時データの混入を防ぐ除外パターン
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
| `rules/` | `.claude/rules/` へコピー | 原則は参照用。個別に移植が必要 |
| `agents/`, `commands/`, `settings.json` | Claude Code向け定義・設定 | 非互換 |
| `skills/` | `.claude/skills/` へコピー | 一括コピー不可。個別の移植・検証が必要 |
| `.agents/skills/` | — | この設定集を保守するCodex用スキル |

同じ目的のファイルでもランタイムごとに形式や読み込み方が異なる。導入前に必ず [COMPATIBILITY.md](./COMPATIBILITY.md) で分類を確認すること。

### `CLAUDE.md` と `rules/common/` の重複について

**同じ規約が両方に存在するのは意図的**（配布形態が 2 通りあるため）。`CLAUDE.md` だけをコピーする配布先と、`rules/common/` をモジュールとして使う配布先の両方で成立させる必要がある。

**ただし両方を手で書き分けると、意味の同じ箇所が独立に編集されて必ずずれる。** 文面を変えるときは **`rules/common/` 側を先に直し、`CLAUDE.md` 側はその変換結果にする**。変換は 3 つ。

1. **見出しを 1 段下げる**（`## X` → `### X`、`### X` → `#### X`）
2. **段落の折り返しを畳む**（日本語なので連結に空白を入れない。表と箇条書きは畳まない）
3. **他ファイルへの相対リンクを置き換える。** `CLAUDE.md` は**単体でプロジェクトへコピーされる**ため、`rules/` 配下を指す相対リンクは配布先で解決しない。`CLAUDE.md` 側に同等の節があれば「下記「…」」へ、無ければバッククォートのフルパス（`` `rules/common/code-review.md` ``）へ書き換える

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
  - `rules/common/` をモジュールとして使う場合 — `worktree.md`（`ready/` 規約）＋ `development-workflow.md`（手順9〜10）＋ `git-workflow.md`（マージ・版上げの委譲先）＋ このスキル
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

今回取り込んだ共通規約は、合意済みの範囲を勝手に縮小しないこと、機能削除前に実利用を調査すること、ビルドだけでなく適切な動作確認を行うこと、レビューが収束しないときは直し方ではなく設計を疑い、範囲を超えるなら相談か切り出しで区切ること。プロジェクト固有のビルド・デプロイ・API・UI仕様は、それぞれのプロジェクトの `AGENTS.md` に残す。

### 1. CLAUDE.md をコピーする場合

`CLAUDE.md` をプロジェクトルートにコピーし、末尾の「プロジェクト固有の設定」セクションに技術スタック・補助コマンド・構成メモを書き込む。それ以外のセクション（変更時の基本フロー・検証・敵対的レビュー・ドキュメント更新等）はそのまま使える想定だが、プロジェクトの運用と食い違う箇所があれば調整する。

### 2. Claude Codeでrulesをコピーする場合

必要なファイルだけを対象プロジェクトの `.claude/rules/common/`（または `rules/java/`, `rules/dotnet/`, `rules/mcp/`）にコピーする。ファイル同士が相対リンクで参照し合っている点に注意する:

- `rules/common/` 内は同階層への参照（例: `[worktree.md](./worktree.md)`）
- `rules/java/` `rules/dotnet/` の各ファイルは対応する `rules/common/` ファイルへの上位階層参照（例: `[testing.md](../common/testing.md)`）を前提にした**差分**として書かれているため、言語別ルールだけをコピーする場合は対応する `rules/common/` ファイルも必ず一緒にコピーする

コピー後は次の2点を確認する:

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

## 注意事項

- 各ファイルはコピー元プロジェクト（Java/Spring MVC ベースのレガシー端末エミュレータ）から汎用化・言語固有部分の切り出しを行ったもの。汎用化の過程で見落としがあれば、使用時に気づいた範囲で直接修正してよい
- 社内固有の情報（ホスト名・チケット番号・個人のメモリキー参照等）は含まれない想定。コピー先プロジェクトの固有情報は各プロジェクト側で追記すること
- **このリポジトリは公開されている**。認証情報（`.credentials.json`）・会話履歴（`history.jsonl`）・組織のポリシー設定（`remote-settings.json` 等）・セッションデータは絶対にコミットしない。`.gitignore` に歯止めを入れてあるが、新しくファイルを追加するときは中身を必ず確認すること
- 個人のペルソナ設定（`~/.claude/CLAUDE.md` のキャラクター設定・`personas/`・`hooks/random-persona.sh`）は意図的に含めていない。必要なら各自の環境で用意すること
