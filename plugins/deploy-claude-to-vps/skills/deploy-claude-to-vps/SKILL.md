---
name: deploy-claude-to-vps
description: ローカルの .claude フォルダ（skills等）をVPS（private-n8n-conoha）の Obsidian Vault に rsync で同期する。「VPSにスキル同期」「.claudeをVPSに反映」等で発動。
user_invocable: true
---

# /deploy-claude-to-vps - .claude フォルダをVPSに同期

ローカルの `.claude/` フォルダの内容を、VPS上の Obsidian Vault に rsync で同期する。
skills の追加・更新後に実行して、VPS側にも反映する。

## 接続情報

- SSH Host: `private-n8n-conoha`
- リモートパス: `/root/projects/obsidian/清水の保管庫/.claude/`

## 除外対象

以下はローカル固有のため同期しない:

- `settings.local.json` — ローカル専用の設定ファイル

## 実行手順

### Step 1: 接続確認

SSH接続が通るか確認する。失敗したら原因を伝えて終了。

```bash
ssh -o ConnectTimeout=5 private-n8n-conoha "echo ok"
```

### Step 2: 差分プレビュー

rsync の `--dry-run` で転送される内容をユーザーに表示する。

```bash
rsync -avz --dry-run --delete \
  --exclude='settings.local.json' \
  /Users/katsu/Documents/private_document/obsidian/.claude/ \
  private-n8n-conoha:'/root/projects/obsidian/清水の保管庫/.claude/'
```

差分の内容をユーザーに見せて、**「この内容で同期してよいですか？」と確認する**。

### Step 3: 同期実行

ユーザーの承認を得てから実行する。

```bash
rsync -avz --delete \
  --exclude='settings.local.json' \
  /Users/katsu/Documents/private_document/obsidian/.claude/ \
  private-n8n-conoha:'/root/projects/obsidian/清水の保管庫/.claude/'
```

### Step 4: 結果報告

- 同期されたファイル数
- 追加・更新・削除されたファイルがあれば一覧
- エラーがあれば内容

## ルール

- **必ず dry-run で差分を見せてからユーザーに確認する**（いきなり同期しない）
- `settings.local.json` は同期しない（ローカル固有設定）
- `--delete` でリモート側の不要ファイルも削除する（ローカルを正とする一方向同期）
- エラー時は原因を調べて対処法を提示する
