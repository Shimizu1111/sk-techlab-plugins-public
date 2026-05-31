---
name: ad-peatix-fetch
description: Peatixダッシュボードのスクリーンショットを取得し、データを読み取ってObsidianに記録する。
user_invocable: true
---
# /ad-peatix-fetch - Peatixデータ取得・記録

Peatixダッシュボードのスクリーンショットを自動取得し、データを読み取って事業数字に記録する。

## 前提

- Chromeがインストール済み
- Chrome Profile 6 = katsunori.shimizu345@gmail.com（Peatixアカウント）
- 実行前にChromeを閉じる必要あり
- Playwrightインストール済み（`~/Documents/dev/selenium-env/`）

## 対象イベント

| イベント名 | ID | URL |
|---|---|---|
| 初心者セミナー | 5023425 | https://peatix.com/event/5023425/dashboard |
| 実践セミナー | 5021236 | https://peatix.com/event/5021236/dashboard |

※イベント追加時は `.scripts/peatix-fetch.py` の `DASHBOARD_URLS` を編集する

## 実行手順

### Step 1: スクリーンショット取得

```bash
python3 .scripts/peatix-fetch.py
```

スクリーンショットが `/tmp/peatix-screenshots/` に保存される。

### Step 2: データ読み取り

保存されたスクリーンショットをReadツールで画像として読み込み、以下の情報を抽出する:

各イベントごとに:
- 申し込み数（/定員数）
- チケット種別ごとの内訳
- 売上合計
- ページビュー推移（グラフから目視で読み取り）
- 流入元の内訳（円グラフから目視で読み取り）

※スクレイピング（HTML解析）ではなくスクリーンショット+AI読み取り方式を採用。
  理由: Peatixの画面構造が変わってもスクリプト修正不要で運用が楽。

### Step 3: Obsidianに記録

抽出したデータを以下に記録する:

**保存先:** `事業数字/Peatix/YYYY-MM-DD_peatix.md`

**フォーマット:**

```markdown
---
date: YYYY-MM-DD
type: peatix-data
---

# Peatixデータ（YYYY-MM-DD取得）

## 初心者セミナー（ID: 5023425）
- 申し込み数: X名
- チケット内訳: {種別ごと}
- 売上: ¥X
- ページビュー: {期間とPV数}
- 流入元: {上位3つ程度}

## 実践セミナー（ID: 5021236）
- 申し込み数: X名
- チケット内訳: {種別ごと}
- 売上: ¥X
- ページビュー: {期間とPV数}
- 流入元: {上位3つ程度}

## 前回比較
{前回のpeatixデータがあれば変化を記載}

## 所感
{数字から気づいたことを1-2行}
```

### Step 4: business-data.jsonの更新

Peatixのデータを `事業数字/data/business-data.json` の該当チャネルの `peatix_registrations` に反映する。

## 使用例

```
/ad-peatix-fetch
→ Peatixデータを取得してObsidianに記録
```
