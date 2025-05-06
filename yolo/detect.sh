#!/usr/bin/env bash
set -e

# args
IN_IMG="$1"
OUT_IMG="$2"

cd /opt/darknet || exit 1

# model files
DATA="cfg/coco.data"
CFG="cfg/yolov3.cfg"
WEIGHTS="yolov3.weights"

# run inference
if command -v nvidia-smi &>/dev/null && \
   nvidia-smi --query-gpu=name --format=csv,noheader | grep . &>/dev/null; then
  echo "[entrypoint] GPU found – running CUDA"
  ./darknet detector test \
    "$DATA" "$CFG" "$WEIGHTS" \
    "$IN_IMG" \
    -dont_show -ext_output > /dev/null
else
  echo "[entrypoint] No GPU – falling back to CPU"
  ./darknet detector test \
    "$DATA" "$CFG" "$WEIGHTS" \
    "$IN_IMG" \
    -nogpu -dont_show -ext_output > /dev/null
fi

if [ ! -f predictions.jpg ]; then
  echo "ERROR: predictions.jpg not found!" >&2
  exit 1
fi

cp predictions.jpg "$OUT_IMG"

