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
| `obs-audit-context` | Obsidian VaultのCLAUDE.md・_index.md・MEMORY・rulesを監査し、不足があれば構築・修正。 |
| `security-check` | インターネット公開前のセキュリティチェック。秘密情報漏洩、認証・認可、インジェクション等を網羅的に検査。 |
| `threads-stock` | 後で語りたいSNS投稿ネタをアカウントごとにストック。インタビューで深掘りする前段階。 |
| `fb-draft` | 投稿ネタからFacebook投稿ルールに沿った下書き生成。複数パターン・画像プロンプト・投稿前チェック付き。 |
| `threads-global-research` | 海外のClaude Code活用事例を、ターゲットに刺さる形で調査・翻訳してVaultに蓄積。 |
| `threads-news-research` | Claude Code・AI関連の最新ニュースを、ターゲットに刺さる形で調査してVaultに蓄積。 |
| `threads-tips-research` | 海外のClaude Codeノウハウ・Tipsを、ターゲットに刺さる形で調査・翻訳してVaultに蓄積。 |
| `ad-peatix-fetch` | Peatixダッシュボードのスクリーンショット取得＋AI読み取りでデータをObsidianに記録。 |
| `x-draft` | 投稿ネタからX投稿ルールに沿った下書き生成。140文字制限・スレッド対応・投稿前チェック付き。 |
| `threads-draft` | 投稿ネタからThreads下書き生成。複数パターン・ソース検証・X版同時生成対応。 |
| `threads-interview` | 対話形式で最近の活動を深掘り、SNS投稿ネタを発掘するインタビュースキル。 |
| `x-analytics` | X投稿のパフォーマンス分析。ファネル分析・コンテンツ分析・前回比較・改善提案。 |
| `ad-analysis` | 広告データ分析＋PDCAサイクル。ファネル分析・ボトルネック特定・打ち手管理。Meta/X広告API対応。 |
| `youtube-transcript-summary` | YouTube動画の文字起こし＆充実まとめ。自動字幕取得・全文読み切り・詳細まとめ。 |
