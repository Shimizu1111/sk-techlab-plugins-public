#!/bin/bash
# run-agent.sh - サブエージェントを実行するヘルパー
# Usage: ./run-agent.sh <agent> <prompt> [cwd]
#   agent: claude | codex | gemini
#   prompt: 実行するプロンプト
#   cwd: 作業ディレクトリ（省略時はカレント）

set -euo pipefail

AGENT="${1:?Usage: run-agent.sh <claude|codex|gemini> <prompt> [cwd]}"
PROMPT="${2:?Prompt is required}"
CWD="${3:-$(pwd)}"
TIMEOUT=300  # 5分タイムアウト

cd "$CWD"

run_claude() {
  timeout "${TIMEOUT}" claude --print --dangerously-skip-permissions \
    -p "$PROMPT" \
    --allowedTools "Bash Edit Write Read Glob Grep" \
    2>&1
}

run_codex() {
  echo "" | timeout "${TIMEOUT}" codex exec "$PROMPT" 2>&1
}

run_gemini() {
  timeout "${TIMEOUT}" gemini -p "$PROMPT" 2>&1
}

# 実行 & フォールバック
echo "=== [$AGENT] 実行開始 ==="

case "$AGENT" in
  codex)
    if OUTPUT=$(run_codex); then
      echo "$OUTPUT"
    else
      EXIT_CODE=$?
      echo "=== [codex] 失敗 (exit=$EXIT_CODE), Claude Code にフォールバック ==="
      run_claude
    fi
    ;;
  gemini)
    if OUTPUT=$(run_gemini); then
      echo "$OUTPUT"
    else
      EXIT_CODE=$?
      echo "=== [gemini] 失敗 (exit=$EXIT_CODE), Claude Code にフォールバック ==="
      run_claude
    fi
    ;;
  claude)
    run_claude
    ;;
  *)
    echo "Unknown agent: $AGENT" >&2
    exit 1
    ;;
esac

echo "=== [$AGENT] 実行完了 ==="
