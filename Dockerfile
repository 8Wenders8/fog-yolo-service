# Dockerfile
FROM python:3.11-slim
WORKDIR /app

# Install your FastAPI + HTTP server (no [h3] extras needed)
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/main.py .

# Expose only the HTTP port
EXPOSE 8000

# Hypercorn serves plain HTTP;
# Traefik will speak TLS/QUIC to the outside.
CMD ["hypercorn", "main:app", "--bind", "0.0.0.0:8000"]

