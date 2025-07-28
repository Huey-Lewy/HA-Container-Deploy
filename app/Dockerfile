# Use Python 3.12.3 slim as base image
FROM python:3.12.3-slim

# Set working directory inside container (/app)
WORKDIR /app

# Install Python dependencies (requirements.txt)
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src/ .

# Expose application port
EXPOSE 8000

# Launch the application
CMD ["python", "main.py"]
