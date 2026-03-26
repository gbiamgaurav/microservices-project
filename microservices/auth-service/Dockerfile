# Build stage
FROM python:3.11-slim AS builder
WORKDIR /app
COPY microservices/auth-service/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY microservices/auth-service/app.py .

ENV PATH=/root/.local/bin:$PATH
ENV FLASK_APP=app.py

EXPOSE 5001

CMD ["python", "app.py"]
