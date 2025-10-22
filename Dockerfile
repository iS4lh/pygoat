FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies for psycopg2 and DNS tools
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        libpq-dev \
        gcc \
        dnsutils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Run database migrations
RUN python manage.py migrate

# Expose app port
EXPOSE 8000

# Start the app using gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
