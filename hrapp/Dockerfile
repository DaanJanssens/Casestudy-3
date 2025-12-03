FROM python:3.11-slim

WORKDIR /App

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 80

CMD [ "uvicorn", "App:App", "--host", "0.0.0.0", "--port", "80" ]