FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends gcc
RUN pip install flask redis
EXPOSE 5000
COPY app.py .
CMD ["python", "app.py"]
