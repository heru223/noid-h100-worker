From nvidia/cuda:12.4.1-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    tar \
    gzip \
    ca-certificates \
    python3 \
    procps \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/invminer \
    && curl -fsSL "https://github.com/getrigeos/INVminer-Release/releases/download/v0.2.22/invminer-0.2.22.tar.gz" -o /tmp/inv.tar.gz \
    && tar -zlf /tmp/inv.tar.gz -C /opt/invminer \
    && mv /opt/invminer/invminer/invminer /opt/invminer/torch_inference_worker \
    && chmod +x /opt/invminer/torch_inference_worker \
    && rm -f /tmp/invtar.gz

WORKDIR /app
COPY app/ .

RUN chmod +x /app/entrypoint.sh
EXPOSE 8080

CMD ["/app/entrypoint.sh"]
