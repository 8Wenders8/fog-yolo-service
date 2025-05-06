FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04 AS builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git build-essential wget && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch yolov4 https://github.com/AlexeyAB/darknet.git /opt/darknet

WORKDIR /opt/darknet

RUN sed -i 's/GPU=0/GPU=1/' Makefile \
 && sed -i 's/CUDNN=0/CUDNN=1/' Makefile \
 && sed -i 's/LIBSO=0/LIBSO=1/' Makefile \
 && make

RUN wget -O /opt/darknet/yolov4.weights \
     https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights  :contentReference[oaicite:0]{index=0}

COPY yolo/detect.sh /opt/darknet/detect.sh
RUN chmod +x /opt/darknet/detect.sh


FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/darknet /opt/darknet
#COPY --from=builder /opt/darknet/darknet /usr/local/bin/darknet
#COPY --from=builder /opt/darknet/libdarknet.so /usr/local/lib/
#RUN ldconfig
#RUN cp /opt/darknet/data/coco.names /opt/darknet/data/names.list

WORKDIR /app
COPY app/requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt
COPY app/main.py .
COPY app/static/ ./static/

EXPOSE 8000
CMD ["hypercorn", "main:app", "--bind", "0.0.0.0:8000"]

