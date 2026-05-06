FROM python:3.14-slim

# Install dependencies including wget
RUN apt-get update && apt-get install -y \
    wget \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    fontconfig \
    libjpeg62-turbo \
    libpng16-16 \
    libx11-6 \
    libxcb1 \
    xfonts-75dpi \
    xfonts-base \
    && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf for Debian 12 (Bookworm)
RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb && \
    apt-get update && \
    apt install -y ./wkhtmltox_0.12.6.1-3.bookworm_amd64.deb && \
    rm wkhtmltox_0.12.6.1-3.bookworm_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy files
COPY . /app

# Install Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Default command
CMD ["python", "main.py"]