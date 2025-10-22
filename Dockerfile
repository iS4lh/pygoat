# Use official Python slim image
FROM python:3.11-slim-buster

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# System dependencies for psycopg2 and building Python packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    python3-dev \
    dnsutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Python environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Upgrade pip
RUN python -m pip install --no-cache-dir --upgrade pip

# Copy only requirements first to leverage Docker cache
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project
COPY . /app/

# Expose port
EXPOSE 8000

# Add entrypoint for migrations + running the app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Use entrypoint to run migrations before starting gunicorn
ENTRYPOINT ["/app/entrypoint.sh"]
