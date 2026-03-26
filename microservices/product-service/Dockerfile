FROM python:3.11-slim AS builder
WORKDIR /app
COPY microservices/product-service/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY microservices/product-service/app.py .

ENV PATH=/root/.local/bin:$PATH
ENV FLASK_APP=app.py

EXPOSE 5003

CMD ["python", "app.py"]
