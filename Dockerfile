FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9-alpine3.14

# Dummy line to trigger finding in Docker linters (ie: use COPY instead of ADD)
ADD LICENSE LICENSE

# Update system packages to improve security posture
RUN apk update && \
    apk upgrade

# Copy application code
COPY app/main.py /app/main.py
