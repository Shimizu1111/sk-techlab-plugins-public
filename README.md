# sk-techlab-plugins-public

SK Tech Lab が公開する Claude Code プラグイン集です。

## インストール方法

```bash
# 1. マーケットプレイスを追加（初回のみ）
claude plugins marketplace add Shimizu1111/sk-techlab-plugins-public

# 2. 使いたいプラグインをインストール
claude plugins install learn-claude-code
```

## プラグイン一覧

| プラグイン | 説明 |
|-----------|------|
| `learn-claude-code` | Claude Codeを30日で使いこなすための学習カリキュラム。1日1トピックずつ進める。 |
| `learn-skills` | Claude Codeのスラッシュコマンドを30日で全て習得。1日1コマンドずつ学ぶ。 |
| `launch-service` | SaaS/Webサービス立ち上げに必要な法務・ビジネス・技術面のチェックを対話形式で進め、ローンチ可否を判定。 |
| `orchestrate` | ユーザーの要求を複数タスクに分解し、最適なAI CLIエージェント（Claude Code / Codex / Gemini CLI）に振り分けて並行実行。 |
| `plan` | やりたいことを整理してJSONに保存するタスクプランニング。保存したプランは `/orchestrate` で実行可能。 |
| `find-code-gaps` | コードベースを探索し、未完成・不足機能を一覧で提示。非ITの人でも理解できる言葉で出力。 |
| `suggest-features` | コードベースを探索し、既存機能を踏まえて「あるとより良くなる機能」をアイデアとして提案。 |
