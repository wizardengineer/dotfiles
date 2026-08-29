#!/usr/bin/env bash
set -euo pipefail

HOST="${LLAMA_FIM_HOST:-127.0.0.1}"
PORT="${LLAMA_FIM_PORT:-8012}"
CTX_SIZE="${LLAMA_FIM_CTX_SIZE:-16384}"
GPU_LAYERS="${LLAMA_FIM_GPU_LAYERS:-99}"
# llama.vim FIM preset values (context-shift cache reuse + larger batches).
# Flash attention is intentionally not passed: this build defaults to --flash-attn auto.
CACHE_REUSE="${LLAMA_FIM_CACHE_REUSE:-256}"
BATCH_SIZE="${LLAMA_FIM_BATCH_SIZE:-2048}"
UBATCH_SIZE="${LLAMA_FIM_UBATCH_SIZE:-1024}"
MODEL_PATH="${LLAMA_FIM_MODEL_PATH:-$HOME/models/qwen/qwen2.5-coder-7b-q8_0.gguf}"

if [[ ! -f "$MODEL_PATH" ]]; then
  echo "Model not found: $MODEL_PATH" >&2
  echo "Download it first, e.g.:" >&2
  echo "  hf download ggml-org/Qwen2.5-Coder-7B-Q8_0-GGUF qwen2.5-coder-7b-q8_0.gguf --local-dir ~/models/qwen" >&2
  exit 1
fi

exec llama-server \
  -m "$MODEL_PATH" \
  --host "$HOST" \
  --port "$PORT" \
  --ctx-size "$CTX_SIZE" \
  --cache-prompt \
  --cache-reuse "$CACHE_REUSE" \
  --batch-size "$BATCH_SIZE" \
  --ubatch-size "$UBATCH_SIZE" \
  -ngl "$GPU_LAYERS"
