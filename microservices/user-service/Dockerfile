FROM python:3.11-slim AS builder
WORKDIR /app
COPY microservices/user-service/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY microservices/user-service/app.py .

ENV PATH=/root/.local/bin:$PATH
ENV FLASK_APP=app.py

EXPOSE 5002

CMD ["python", "app.py"]
