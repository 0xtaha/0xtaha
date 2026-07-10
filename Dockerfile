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

# Copy only application code and project metadata into the image
COPY pyproject.toml main.py style.css /app/

# Install UV and use it to install Python dependencies from pyproject.toml
RUN python -m pip install --no-cache-dir uv && \
    uv install

# Default command
CMD ["python", "main.py"]