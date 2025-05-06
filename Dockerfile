FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04 AS builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git build-essential wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN git clone https://github.com/AlexeyAB/darknet.git && \
    cd darknet && \
    sed -i 's/GPU=0/GPU=1/' Makefile && \
    sed -i 's/CUDNN=0/CUDNN=1/' Makefile && \
	sed -i 's/LIBSO=0/LIBSO=1/' Makefile && \
    make

RUN wget -O /opt/darknet/yolov3.weights \
      https://pjreddie.com/media/files/yolov3.weights

COPY yolo/detect.sh /opt/darknet/detect.sh
RUN chmod +x /opt/darknet/detect.sh


FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/darknet /opt/darknet

WORKDIR /app
COPY app/requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt
COPY app/main.py .
COPY app/static/ ./static/

EXPOSE 8000
CMD ["hypercorn", "main:app", "--bind", "0.0.0.0:8000"]

