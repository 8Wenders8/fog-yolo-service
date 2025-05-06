FROM nvidia/cuda:11.7-runtime

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git build-essential python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/pjreddie/darknet.git /opt/darknet && \
    cd /opt/darknet && \
    sed -i 's/GPU=0/GPU=1/' Makefile && \
    sed -i 's/CUDNN=0/CUDNN=1/' Makefile && \
    make

COPY yolo/detect.sh /opt/darknet/detect.sh
RUN chmod +x /opt/darknet/detect.sh

WORKDIR /app
COPY app/requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
COPY app/main.py .
COPY app/static/ .


EXPOSE 8000
CMD ["hypercorn", "main:app", "--bind", "0.0.0.0:8000"]

