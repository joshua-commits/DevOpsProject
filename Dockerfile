# Dockerfile for the Flask application

FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# Expose port 5000. runs locally if port not exposed

CMD ["python", "hello.py"]