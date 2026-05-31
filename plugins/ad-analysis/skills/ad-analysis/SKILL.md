---
name: ad-analysis
description: 広告データを分析し、レポートをObsidianに蓄積。打ち手の記録と観測のPDCAサイクルを回すスキル。
user_invocable: true
---
# /ad-analysis - 広告分析・打ち手管理

広告データを取り込み、分析レポートをObsidianノートとして蓄積する。
打ち手を記録→次回分析時に効果を観測する、PDCAサイクルスキル。

## 引数

- `$ARGUMENTS` にモードを指定（省略時は自動判定）
  - `fetch` - 全プラットフォームの広告データを自動取得（API経由）
  - `fetch meta` - Meta広告データのみ取得
  - `fetch x` - X広告データのみ取得
  - `report` - 分析レポート生成
  - `manage` - 広告の管理操作（予算変更、配信ON/OFF等）
  - `manage meta` - Meta広告の管理操作
  - `manage x` - X広告の管理操作
  - `input` - データ入力（数字を会話で入力）
  - `action` - 打ち手の記録・更新
  - `review` - 過去の打ち手の効果振り返り

## API セットアップ

### Meta API

1. https://developers.facebook.com/ → アプリ作成 → 「マーケティングAPIで広告を作成・管理」を選択
2. ツール → Graph APIエクスプローラ を開く
3. Metaアプリで作成したアプリを選択し、「ユーザーアクセストークンを取得」を選択
4. 「許可を追加」→ `ads_management` を追加（データ取得+広告管理の両方が可能）
5. 「Generate Access Token」でトークン生成
6. `.env` に以下を設定:
   ```
   META_ACCESS_TOKEN=生成したトークン
   META_AD_ACCOUNT_ID=広告アカウントID
   ```
   - 広告アカウントIDは広告マネージャURLの `act=` の後の数字

**トークンの有効期限:**
- Graph API Explorerで生成した短期トークンは約1時間で失効
- 長期トークン（60日）に交換するには:
  ```
  curl "https://graph.facebook.com/v21.0/oauth/access_token?grant_type=fb_exchange_token&client_id={APP_ID}&client_secret={APP_SECRET}&fb_exchange_token={SHORT_TOKEN}"
  ```
- トークン期限切れ時はGraph API Explorerで再生成

### X (Twitter) Ads API

1. https://developer.x.com/ でアプリを選択（例: x-management-katsu）
2. アプリの「Keys and tokens」から以下を取得:
   - Consumer Key (API Key)
   - Consumer Secret (API Secret)
   - Access Token
   - Access Token Secret
3. `.env` に以下を設定:
   ```
   X_ADS_ACCOUNT_ID=広告アカウントID
   X_CONSUMER_KEY=Consumer Key
   X_CONSUMER_SECRET=Consumer Secret
   X_ACCESS_TOKEN=Access Token
   X_ACCESS_TOKEN_SECRET=Access Token Secret
   ```
   - 広告アカウントIDは ads.x.com の左上に表示されるID（例: 18ce55vuduf）

**注意:**
- X Ads APIには別途アクセス申請が必要な場合がある（403エラーが出たら申請が必要）
- トークンは Developer Portal で再生成可能（有効期限なし）

## スクリプト

| スクリプト | 用途 |
|---|---|
| `.scripts/meta-ads-fetch.py` | Meta広告データ取得 → ad-data.json に保存 |
| `.scripts/meta-ads-manage.py` | Meta広告管理（一覧表示、予算変更、配信ON/OFF） |
| `.scripts/x-ads-fetch.py` | X広告データ取得 → ad-data.json に保存 |
| `.scripts/x-ads-manage.py` | X広告管理（一覧表示、配信ON/OFF） |

## フォルダ構成

```
事業数字/
├── data/
│   └── business-data.json      ← 事業ファネルデータ
├── 分析レポート/
│   └── YYYY-MM-DD_分析.md      ← 分析レポート（蓄積）
├── 打ち手ログ/
│   └── actions.md              ← 打ち手の一覧と状況
└── 広告運用/
    └── data/
        └── ad-data.json        ← 広告日別データ
```

## 実行手順

### Step 0: 現状把握

まず以下を読み込む:

1. `事業数字/data/business-data.json` - 現在の事業数字
2. `事業数字/打ち手ログ/actions.md` - 実行中の打ち手（あれば）
3. `事業数字/分析レポート/` - 直近の分析レポート（最新1-2件、あれば）
4. `事業数字/広告運用/data/ad-data.json` - 広告日別データ（あれば）
5. `目標設定/10年計画.md` - 事業目標（初回のみ）

引数がなければ、現状に応じてモードを自動判定:
- データがない/古い → `fetch` モードを提案（.env設定済みなら）、未設定なら `input` を提案
- 未レビューの打ち手がある → `review` を提案
- それ以外 → `report` で分析開始

### Step 0.5: 広告データ自動取得モード（fetch）

API経由で広告データを自動取得し、`ad-data.json` に保存する。

**実行:**

```bash
# 両プラットフォーム（Meta + X）を順に取得
python3 .scripts/meta-ads-fetch.py --days 7
python3 .scripts/x-ads-fetch.py --days 7

# Meta のみ
python3 .scripts/meta-ads-fetch.py --days 7

# X のみ
python3 .scripts/x-ads-fetch.py --days 7
```

オプション（共通）:
- `--days 7` - 過去7日分（デフォルト）
- `--since 2026-05-01 --until 2026-05-31` - 期間指定

**フロー:**
1. 引数に応じたスクリプトを実行してデータ取得（引数なし or `fetch` のみは両方）
2. 取得結果のサマリーをユーザーに表示
3. 自動的に `report` モードに移行して分析開始

**エラー時:**
- トークン期限切れ → 該当プラットフォームの「APIセットアップ」セクションの手順を案内
- `.env` 未設定 → セットアップ手順を案内し、`input` モードにフォールバック
- 403エラー（X）→ X Ads APIアクセス申請が必要な旨を案内

### Step 0.6: 広告管理モード（manage）

分析結果に基づいて、広告の設定をAPI経由で直接変更する。

**Meta広告でできること:**

| 操作 | コマンド | 説明 |
|---|---|---|
| 構造一覧 | `meta-ads-manage.py list` | キャンペーン/広告セット/広告のツリー表示 |
| 詳細確認 | `meta-ads-manage.py detail <campaign_id>` | キャンペーンの詳細+直近7日パフォーマンス |
| 予算変更 | `meta-ads-manage.py budget <adset_id> <円>` | 広告セットの日予算を変更 |
| 配信停止 | `meta-ads-manage.py pause <type> <id>` | campaign/adset/ad を停止 |
| 配信再開 | `meta-ads-manage.py resume <type> <id>` | campaign/adset/ad を再開 |

**X広告でできること:**

| 操作 | コマンド | 説明 |
|---|---|---|
| 構造一覧 | `x-ads-manage.py list` | キャンペーン/ラインアイテムのツリー表示 |
| 詳細確認 | `x-ads-manage.py detail <campaign_id>` | キャンペーンの詳細+直近7日パフォーマンス |
| 配信停止 | `x-ads-manage.py pause <type> <id>` | campaign/line_item を停止 |
| 配信再開 | `x-ads-manage.py resume <type> <id>` | campaign/line_item を再開 |

**安全ルール（重要）:**
- 変更操作（budget/pause/resume）は**必ずユーザーに確認してから実行**する
- 確認時は「現在の値 → 変更後の値」を明示する
- 一度に複数の変更をまとめて実行しない（1つずつ確認→実行）
- 配信停止は売上に直結するため、特に慎重に確認する

**典型的なフロー:**

```
1. /ad-analysis manage
2. まず `list` で現在の構造を確認
3. ユーザーの要望を聞く（例: 「予算を3000円に上げたい」「この広告止めて」）
4. 変更内容を明示して確認
5. 承認後に実行
```

**reportモードとの連携:**
- 分析レポートで「この広告セットのCPAが高い」→ そのまま `manage` で予算調整や停止が可能
- 打ち手として「予算を○円に変更」を提案 → ユーザー承認 → その場で実行+打ち手ログに記録

### Step 1: データ入力モード（input）

ユーザーから数字を会話形式で聞き取り、`business-data.json` に保存する。

**聞き取る項目（チャネル別）:**

```
「今月（or 今週）の数字を教えて。チャネル別に聞くね。」

Meta広告:
- 広告費はいくら使った？
- Peatixに何人登録あった？
- 面談申込は何件？
- 面談実施は何件？
- 成約は何件？いくらの案件？

SNS自然流入:
- （同上）

紹介・BNI:
- （同上）
```

**入力のルール:**
- 「わからない」「まだない」は0として記録し、備考に「未計測」と記録
- ざっくりの数字でもOK。「だいたい3万くらい」→ 30000で記録
- 既にデータがある月は上書き確認する
- 入力完了後、自動的にreportモードに移行する

### Step 2: 分析レポートモード（report）

データを元に分析レポートを生成し、Obsidianノートとして保存する。

**分析の観点:**

#### 2-1. ファネル健康度チェック

全チャネル合算のファネルを算出し、各ステップの転換率を評価する。

```
広告費 ¥XX → Peatix XX名 → 面談申込 XX件 → 面談実施 XX件 → 成約 XX件 → 売上 ¥XX

転換率:
- Peatix → 面談申込: XX%（目安: 20-30%）
- 面談申込 → 実施: XX%（目安: 70-80%）
- 面談実施 → 成約: XX%（目安: 20-40%）
```

各ステップに「良好 / 改善余地あり / 要改善」の判定をつける。

#### 2-2. ボトルネック特定

ファネルの中で最も転換率が低い（=最もインパクトが大きい）ステップを1つ特定する。

```
「最大のボトルネック: 面談→成約の転換率が15%で目安(30%)の半分。
ここを改善すると、同じ広告費で成約数が2倍になる可能性がある。」
```

#### 2-3. チャネル別ROI比較

各チャネルの「1件成約にかかったコスト」を比較する。

```
- Meta広告: 広告費¥50,000 → 成約1件 → CPA ¥50,000 / 売上 ¥300,000 → ROI 500%
- SNS自然流入: コスト¥0 → 成約1件 → ROI ∞
- BNI: 会費¥XX → 成約0件 → ROI -
```

#### 2-4. 目標との差分

月商目標との差分を算出し、「あと何が必要か」を逆算する。

```
目標: 月商200万
現在: 月商60万（達成率30%）

あと140万必要 → 平均成約単価30万として → あと4.7件成約が必要
→ 成約率30%として → あと16件面談が必要
→ 面談申込率25%として → あと64人のPeatix登録が必要
```

#### 2-5. 前回比較（2回目以降）

前回の分析レポートがあれば、変化を比較する。

```
前回(5/24) → 今回(5/31):
- 広告費: ¥30,000 → ¥50,000（+67%）
- CPA: ¥15,000 → ¥10,000（-33% 改善）
- 成約率: 20% → 25%（+5pt）
```

#### 2-6. 打ち手の効果確認

実行中の打ち手があれば、その効果を数字で評価する。

```
打ち手「広告クリエイティブをビフォーアフター型に変更」(5/20開始):
- 変更前CTR: 1.2% → 変更後CTR: 1.8%（+50%改善）
- 判定: 効果あり。継続推奨。
```

### Step 3: 打ち手の提案

分析結果をもとに、**最大2つ**の具体的なアクションを提案する。

**提案のルール:**
- ボトルネックに直結するアクションを優先
- 「広告費を増やす」のような抽象的な提案はNG
- 「Meta広告のLP見出しを"○○"から"△△"に変更してCTRを1.5%→2.0%を狙う」のように具体的に
- 各アクションに「期待効果」「計測方法」「判定期間」を明記
- ADHD気質を考慮し、やることを絞る

**提案フォーマット:**

```
【打ち手1】{タイトル}
- 具体的にやること: {1-2行で}
- 期待効果: {どの数字がどう変わるか}
- 計測方法: {何を見ればわかるか}
- 判定期間: {何日後に効果を見るか}
- 優先度: 高/中
```

### Step 4: 打ち手の記録（action）

ユーザーが打ち手を採用したら、`打ち手ログ/actions.md` に記録する。

**actions.md のフォーマット:**

```markdown
# 打ち手ログ

## 実行中

### [A001] {タイトル}
- 開始日: YYYY-MM-DD
- 具体的にやること: {内容}
- 期待効果: {数字の目標}
- 計測方法: {何を見るか}
- 判定予定日: YYYY-MM-DD
- ステータス: 実行中
- 経過メモ:
  - YYYY-MM-DD: {メモ}

## 完了・判定済み

### [A000] {タイトル}
- 開始日: YYYY-MM-DD
- 判定日: YYYY-MM-DD
- 結果: 効果あり / 効果なし / 判断保留
- 数字の変化: {ビフォーアフター}
- 学び: {次に活かすこと}
```

### Step 5: レポート保存

分析結果を Obsidian ノートとして保存する。

**保存先:** `事業数字/分析レポート/YYYY-MM-DD_分析.md`

**レポートのフォーマット:**

```markdown
---
date: YYYY-MM-DD
type: ad-analysis
period: YYYY-MM
---

# 広告分析レポート（YYYY-MM-DD）

## サマリー
{3行以内で現状を要約}

## ファネル全体像
{Step 2-1の内容}

## ボトルネック
{Step 2-2の内容}

## チャネル別ROI
{Step 2-3の内容}

## 目標との差分
{Step 2-4の内容}

## 前回比較
{Step 2-5の内容}

## 打ち手の効果
{Step 2-6の内容}

## 次の打ち手
{Step 3の提案内容}

## 決定事項
{ユーザーが採用した打ち手をここに記録}

---
次回分析予定: YYYY-MM-DD（1週間後）
```

### Step 6: 次回リマインド

レポート保存後、以下を提示:

- 「次回の分析は{1週間後の日付}がおすすめ。`/ad-analysis` で続きからいけるよ」
- 実行中の打ち手があれば「{打ち手名}の判定予定日は{日付}。その頃にまた見よう」
- データ入力が必要な項目があれば「次回までに{項目}の数字を確認しておいて」

## 分析の心得

- **数字がなくても始める。** 「まだ広告出してない」→ 目標逆算と仮説設計はできる
- **完璧な数字を求めない。** ざっくりでいい。正確性より継続性
- **打ち手は最大2つ。** ADHD気質を考慮し、集中すべきことを絞る
- **良いニュースも伝える。** 改善点だけでなく「ここは良い」も明確に
- **判断を押し付けない。** 提案はするが、最終決定はユーザー

## 使用例

```
/ad-analysis
→ 現状を見て最適なモードで開始

/ad-analysis fetch
→ Meta + X 両方の広告データを自動取得してから分析

/ad-analysis fetch meta
→ Meta広告データのみ取得

/ad-analysis fetch x
→ X広告データのみ取得

/ad-analysis manage
→ 広告の管理操作（プラットフォーム選択を聞く）

/ad-analysis manage meta
→ Meta広告の予算変更・配信ON/OFFなどの管理操作

/ad-analysis manage x
→ X広告の配信ON/OFFなどの管理操作

/ad-analysis input
→ 今月の数字を手動入力

/ad-analysis report
→ 分析レポート生成（全プラットフォーム横断）

/ad-analysis action
→ 打ち手の記録・更新

/ad-analysis review
→ 過去の打ち手の効果を振り返り
```
