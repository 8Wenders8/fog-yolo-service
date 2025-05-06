#!/usr/bin/env bash
cd /opt/darknet || exit 1

DATA="cfg/coco.data"
CFG="cfg/yolov3.cfg"
WEIGHTS="yolov3.weights"

if command -v nvidia-smi &>/dev/null && \
   nvidia-smi --query-gpu=name --format=csv,noheader | grep . &>/dev/null; then
  echo "[entrypoint] GPU found – running with CUDA…"
  exec ./darknet detector test "$DATA" "$CFG" "$WEIGHTS" "$@" -ext_output -dont_show
else
  echo "[entrypoint] No GPU – falling back to CPU."
  exec ./darknet detector test "$DATA" "$CFG" "$WEIGHTS" -nogpu "$@" -ext_output -dont_show
fi
