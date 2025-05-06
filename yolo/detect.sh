#!/usr/bin/env bash

DARKNET_BIN=/usr/local/bin/darknet
DATA=/opt/darknet/data/coco.data
CFG=/opt/darknet/cfg/yolov3.cfg
WEIGHTS=/opt/darknet/yolov3.weights

if command -v nvidia-smi &>/dev/null && \
   nvidia-smi --query-gpu=name --format=csv,noheader | grep . &>/dev/null; then
  echo "[entrypoint] GPU found – running with CUDA…"
  exec "$DARKNET_BIN" detector test \
       "$DATA" "$CFG" "$WEIGHTS" \
       "$@" -ext_output -dont_show
else
  echo "[entrypoint] No GPU – falling back to CPU."
  exec "$DARKNET_BIN" detector test \
       "$DATA" "$CFG" "$WEIGHTS" \
       "$@" -nogpu -ext_output -dont_show
fi

