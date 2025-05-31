FROM python:3.10-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    wkhtmltopdf \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*


RUN ln -s $(which wkhtmltopdf) /usr/local/bin/wkhtmltopdf
# Set working directory
WORKDIR /app

# Copy files
COPY . /app

# Install Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Default command
CMD ["python", "main.py"]
