FROM python:3.11-slim

WORKDIR /app

COPY app.py .

RUN pip install flask redis gunicorn

CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--workers", "4"]

