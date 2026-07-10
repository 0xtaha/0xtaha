# Application Documentation

## Overview

`readme-to-pdf` is a Python application that converts a Markdown README file into a formatted PDF document using Playwright (headless Chromium). The application reads your README.md, applies custom CSS styling, and generates a production-ready PDF file.

## Features

- **Markdown to PDF conversion**: Converts README.md to a professional PDF
- **Custom styling**: Apply custom CSS styles via style.css
- **Configurable output**: Set the output filename via environment variable
- **Non-root execution**: Runs as a non-root user `appuser` for enhanced security
- **Docker-ready**: Fully containerized with multi-stage build

## Architecture

### Components

1. **main.py** - Core conversion logic
   - Reads README.md file
   - Applies style.css formatting
   - Generates HTML from Markdown
   - Converts HTML to PDF using Playwright (headless Chromium)

2. **style.css** - Styling configuration
   - Defines layout and typography
   - Controls margins, fonts, and colors
   - Customizes PDF appearance

3. **pyproject.toml** - Project metadata and dependencies
   - Python version requirement: >=3.14
   - Core dependencies: markdown, playwright

## Usage

### Local Execution (with Docker)

Using docker-compose:

```bash
docker-compose up
```

The application will generate `Taha_Abdelaziz_Sr_DevSecOps_Engineer.pdf` by default.

### With Custom Output Filename

```bash
docker-compose run readme-to-pdf -e OUTPUT_PDF=custom-name.pdf
```

### Direct Python Execution

```bash
# Install dependencies
pip install -r pyproject.toml

# Run the conversion
python main.py

# With custom output
OUTPUT_PDF=my-resume.pdf python main.py
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OUTPUT_PDF` | `README.pdf` | Name of the generated PDF file |

## Dependencies

### Runtime Dependencies

- **markdown** - Convert Markdown to HTML
- **playwright** - Python package providing Chromium automation for HTML→PDF rendering
- **Chromium (via Playwright)** - Headless Chromium browser used to render HTML to PDF (installed in Docker base image / final image build)

### System Requirements (Docker)

- Python 3.14-slim
- Chromium and dependencies (libnss3, libatk1.0-0, libgbm1, libpangocairo-1.0-0, fonts-liberation, etc.)
- Non-root user context

## How It Works

1. **Read input files**: Reads README.md and style.css from the working directory
2. **Parse Markdown**: Converts Markdown syntax to HTML5 format
3. **Apply styling**: Wraps HTML with CSS styling and proper document structure
4. **Configure PDF options**: Sets margins (15mm on all sides)
5. **Generate PDF**: Uses wkhtmltopdf to render HTML to PDF
6. **Output**: Saves PDF with the configured filename

## Error Handling

The application will fail with an error if:
- README.md file is not found in the current directory
- style.css file is not found in the current directory
- wkhtmltopdf is not installed or not accessible at `/usr/local/bin/wkhtmltopdf`
- PDF generation fails due to invalid HTML or styling

## Security Considerations

- **Non-root user**: Application runs as unprivileged `appuser` user
- **Read-only README mount**: README.md is mounted read-only in Docker
- **Isolated environment**: Container isolation prevents interference with host system

## Performance

- **Build time**: ~2-3 minutes (base image cached after first build)
- **Conversion time**: ~1-2 seconds per PDF generation
- **Output size**: Typical resume PDF is 100-500 KB depending on content

## Future Enhancements

- Support for multiple output formats (HTML, DOCX)
- Batch PDF generation from multiple Markdown files
- Template system for different resume styles
- Watermark and signature support
- Configuration file for advanced PDF options
