FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9-alpine3.14

LABEL maintainer='@donhector'

RUN apk update && \
    apk upgrade

COPY app/main.py /app/main.py

