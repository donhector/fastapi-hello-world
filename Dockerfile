FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9-alpine3.14
RUN apk update && \
    apk upgrade
COPY main.py /app/main.py

