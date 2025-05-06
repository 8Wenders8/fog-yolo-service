#!/usr/bin/env bash
cd /opt/darknet

if command -v nvidia-smi &>/dev/null && nvidia-smi ...; then
  echo "[entrypoint] GPU found"
  exec ./darknet detector test data/coco.data cfg/yolov3.cfg yolov3.weights \
       "$@" -ext_output -dont_show
else
  echo "[entrypoint] No GPU"
  exec ./darknet detector test data/coco.data cfg/yolov3.cfg yolov3.weights \
       -nogpu "$@" -ext_output -dont_show
fi

