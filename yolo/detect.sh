#!/usr/bin/env bash
if command -v nvidia-smi &>/dev/null && \
   nvidia-smi --query-gpu=name --format=csv,noheader | grep . &>/dev/null; then
  echo "[entrypoint] GPU detected – running with CUDA…"
  exec ./darknet detect cfg/yolov3.cfg yolov3.weights "$@"
else
  echo "[entrypoint] No GPU – falling back to CPU."
  exec ./darknet detect cfg/yolov3.cfg yolov3.weights -nogpu "$@"
fi

