FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9-alpine3.14

ARG VERSION=latest
ARG BUILD_DATE=unset
ARG COMMIT=unset

ENV VERSION=${VERSION}
ENV BUILD_DATE=${BUILD_DATE}
ENV COMMIT=${COMMIT}

LABEL OWNER=donhector

# Dummy line to trigger finding in Docker linters (ie: use COPY instead of ADD)
ADD LICENSE LICENSE

# Update system packages to improve security posture
RUN apk update && \
    apk upgrade

# Copy application code
COPY app/main.py /app/main.py
