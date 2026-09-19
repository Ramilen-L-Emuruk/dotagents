# ランタイム互換性

このリポジトリは Claude Code と Codex の設定資材を併置する。ファイル名や意図が似ていても、読み込み位置・ツール名・フック入力形式は互換ではない。ここを導入時の分類表とする。

## Codex でそのまま使える資材

| 資材 | 用途 | 配置先 |
|---|---|---|
| `AGENTS.md` | この `dotagents` リポジトリを保守するための指示 | リポジトリルート |
| `.agents/skills/agent-config-maintenance/` | この設定集の追加・変更・監査 | リポジトリ内 `.agents/skills/` |
| `templates/codex/AGENTS.md` | 対象プロジェクトのための最小指示テンプレート | 対象リポジトリのルートへコピー後、プロジェクト固有欄を記入 |

Codex はリポジトリの `AGENTS.md` と `.agents/skills/` を検出する。個人設定の `~/.codex/` は共有資材としてコミットしない。

## Claude Code 専用

以下はClaude Codeの設定形式・CLI・フックイベント・実行時データに依存する。Codexへコピーしても同じ動作はしない。

| 資材 | Claude Code 依存の例 |
|---|---|
| `settings.json` | `CLAUDE_CODE_ENABLE_TODO_TOOLS`、`permissions`、`statusLine`、`PreToolUse`／`PostToolUse`、Claudeモデル名 |
| `statusline-command.sh` | Claude Codeのステータスライン入力形式 |
| `commands/` | Claude Codeのカスタムスラッシュコマンド |
| `agents/` | Claude Code向けエージェント定義の配置・形式 |
| `skills/claude-devfleet/` | Claude DevFleet と Claude Code のMCP設定 |
| `skills/continuous-learning/` | Claude CodeのStopフック、トランスクリプト環境変数、`~/.claude/` |
| `skills/continuous-learning-v2/` | Claude CodeのPre/Post Tool Useフック、Claude CLI、`~/.claude/` |
| `skills/strategic-compact/` | Claude CodeのPreToolUseフックとセッション環境変数 |

## 方針は共有できるが、移植が必要な資材

| 資材 | 保てる内容 | Codexへ移す際に直す内容 |
|---|---|---|
| `CLAUDE.md` | 調査、検証、レビュー、リリースの判断基準 | `TaskCreate`、`EnterWorktree`、`ExitWorktree`、`AskUserQuestion`、Claude固有のパスとセッション変数 |
| `rules/common/` | テスト、セキュリティ、レビュー、Git運用の原則 | `.claude/` の出力先、Claudeツール名、Claude用の許可設定、共同著者表記 |
| `rules/java/`, `rules/dotnet/`, `rules/mcp/` | 言語・ツール固有の技術ガイド | Claude Codeのfrontmatter読み込みと `.claude/` パス |
| `skills/` のその他 | 個別スキルごとの手順・専門知識 | Claude用ツール、フック、コマンド、MCP依存を監査してから `.agents/skills/` 用に書き換える |

`skills/` はClaude Code用・外部由来・未監査のスキルを含むソース集であり、Codexへの一括コピー元ではない。Codexへ追加するのは、この表で「そのまま使える」と明記された資材、または個別に移植・検証した資材だけにする。

## 移植の手順

1. スキルやルールの目的を残し、Claude固有のツール名・パス・フックを特定する。
2. Codexで使える手段へ置き換える。代替がない場合は、要件を `AGENTS.md` の手動手順として記録する。
3. Codex用スキルは `.agents/skills/<name>/SKILL.md` に置き、`name` と具体的な `description` をfrontmatterへ付ける。
4. Claude Code版は削除せず併存させ、READMEとこの表を同一変更で更新する。
