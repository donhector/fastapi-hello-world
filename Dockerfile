FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9-alpine3.14

ARG BUILD_DATE
ARG VERSION
ARG COMMIT

LABEL maintainer="@donhector" \
      org.opencontainers.image.title="Fastapi Hello World" \
      org.opencontainers.image.description="Fastapi Hello World example" \
      org.opencontainers.image.authors="@donhector" \
      org.opencontainers.image.vendor="darkenv" \
      org.opencontainers.image.documentation="https://github.com/donhector/fastapi-hello-world/README.md" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://github.com/donhector/fastapi-hello-world" \
      org.opencontainers.image.source="https://github.com/donhector/fastapi-hello-world" \
      org.opencontainers.image.version=${VERSION} \
      org.opencontainers.image.revision=${COMMIT} \
      org.opencontainers.image.created=${BUILD_DATE}

RUN apk update && \
    apk upgrade

COPY app/main.py /app/main.py
