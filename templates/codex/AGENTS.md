# Project Instructions

このファイルを対象リポジトリのルートへ `AGENTS.md` としてコピーし、角括弧の項目をプロジェクトの実情で置き換える。

## Project setup

- Build: `[build command]`
- Test: `[test command]`
- Lint / format: `[lint or format command]`
- Project-specific constraints: `[for example: supported runtime, deployment rule, or generated-file policy]`

## Working agreements

- 実装前に、既存の類似実装・関連する仕様・利用ライブラリの公式ドキュメントを確認する。
- 変更に対応するテストを追加または更新し、影響範囲に適した検証を実行する。
- 変更後は、ユーザー向けの挙動・設定・公開APIが変わる場合に関連ドキュメントを更新する。
- 認証情報、会話履歴、端末固有の設定、生成物をコミットしない。
- 破壊的な操作、依存関係の追加、外部サービスへの書き込みは、必要な確認を取ってから行う。

## Project structure

- Application code: `[path]`
- Tests: `[path]`
- Documentation: `[path]`
- Generated or temporary output: `[path and whether it is ignored]`

## Runtime-specific notes

- Claude Code向けの `CLAUDE.md`、`.claude/`、カスタムコマンド、フックを、このファイルの前提にしない。
- 反復可能なCodexワークフローは `.agents/skills/<name>/SKILL.md` として管理する。
