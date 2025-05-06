#!/usr/bin/env bash
DARKNET_BIN="/usr/local/bin/darknet"

if command -v nvidia-smi &>/dev/null && \
   nvidia-smi --query-gpu=name --format=csv,noheader | grep . &>/dev/null; then
  echo "[entrypoint] GPU detected — running on CUDA…"
  exec "$DARKNET_BIN" detector test cfg/yolov3.cfg yolov3.weights "$@"
else
  echo "[entrypoint] No GPU — falling back to CPU."
  exec "$DARKNET_BIN" detector test cfg/yolov3.cfg yolov3.weights -nogpu "$@"
fi

