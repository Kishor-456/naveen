FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files
COPY . .

# Expose port
EXPOSE 7860

# Health check
HEALTHCHECK CMD python -c "import requests; requests.get('http://localhost:7860', timeout=5)"

# Run the app
CMD ["gunicorn", "--bind", "0.0.0.0:7860", "app:app"]
