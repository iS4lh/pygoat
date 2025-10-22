# Use a stable, maintained Python base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install required system dependencies for psycopg2
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Upgrade pip and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Expose the port
EXPOSE 8000

# Run migrations at build time (optional, usually done at runtime)
RUN python manage.py migrate

# Set default command
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
