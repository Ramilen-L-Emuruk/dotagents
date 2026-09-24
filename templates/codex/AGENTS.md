# Project Instructions

このファイルを対象リポジトリのルートへ `AGENTS.md` としてコピーし、角括弧の項目をプロジェクトの実情で置き換える。

## Project setup

- Build: `[build command]`
- Test: `[test command]`
- Lint / format: `[lint or format command]`
- Project-specific constraints: `[for example: supported runtime, deployment rule, or generated-file policy]`

## Working agreements

- 実装前に、既存の類似実装・関連する仕様・利用ライブラリの公式ドキュメントを確認する。
- 合意済みの対象範囲・深さ・完了条件を、実装側の判断だけで狭めない。変更が必要になったら、根拠と影響を示して確認を取る。
- 機能の削除・代替・「使われていない」という結論の前に、呼び出し元・設定・利用者向け導線を調べ、裏付けを残す。
- 変更に対応するテストを追加または更新し、影響範囲に適した検証を実行する。利用者向け挙動が変わる場合、ビルドや型検査だけで済ませず、安全に実行可能な動作確認も行う。
- レビューは変更の重要度に見合う回数で収束させる。収束しないときは直し方ではなく設計を疑い、まず設計を変える。
- 設計変更が対象範囲を超える場合、直さねばならないものは範囲の拡大を相談し、そうでないものは別タスクへ切り出す。
- 未解決の問題や実施できなかった検証は、何をなぜ残すかを明記して引き継ぐ。
- 変更後は、ユーザー向けの挙動・設定・公開APIが変わる場合に関連ドキュメントを更新する。
- 認証情報、会話履歴、端末固有の設定、生成物をコミットしない。
- 破壊的な操作、依存関係の追加、外部サービスへの書き込みは、必要な確認を取ってから行う。

## Project structure

- Application code: `[path]`
- Tests: `[path]`
- Documentation: `[path]`
- Generated or temporary output: `[path and whether it is ignored]`

## Codex workflows

- 導入時に、設定資材リポジトリの `.codex/agents/` および `.agents/skills/` テンプレートから必要な資材をこのプロジェクトへコピーする。
- 調査・設計・レビュー・検証のように独立した読み取り作業は、適したカスタムエージェントへ並列に委任してよい。複数の書き込みエージェントを同じ作業ツリーで並列実行しない。
- 通常の実装には `development-workflow`、レビューには `code-review`、明示的なリリースには `release`、再利用可能な知見の抽出には `capture-learning`、分離された作業には `worktree-workflow` を使う。
- 各スキルとエージェントは補助であり、ユーザーの明示的な承認が必要なコミット、push、リリース、外部変更を自動化しない。

## Temporary output

- 一時ログは `.codex/logs/`、スクリーンショットは `.codex/screenshots/` に保存する。
- `templates/codex/.gitignore.additions` から利用するパスだけを対象リポジトリの `.gitignore` へマージする。
## Runtime-specific notes

- Claude Code向けの `CLAUDE.md`、`.claude/`、カスタムコマンド、フックを、このファイルの前提にしない。
- 反復可能なCodexワークフローは `.agents/skills/<name>/SKILL.md` として管理する。
