# Documentation

This directory contains comprehensive documentation for the readme-to-pdf application and its supporting infrastructure.

## Quick Navigation

| Document | Purpose |
|----------|---------|
| [APP.md](./APP.md) | Application usage, features, and architecture |
| [DOCKER.md](./DOCKER.md) | Docker configuration, multi-stage builds, and container management |
| [CICD.md](./CICD.md) | GitHub Actions workflows and CI/CD pipeline configuration |
| [PIPELINES.md](./PIPELINES.md) | Detailed pipeline architecture and data flow |

## Documentation at a Glance

### For Application Users

Start with **[APP.md](./APP.md)**:
- What the application does
- How to run it locally or with Docker
- Environment variables and configuration
- Dependencies and requirements

### For Infrastructure/DevOps

Start with **[DOCKER.md](./DOCKER.md)**:
- Multi-stage Docker build strategy
- Image organization and tagging
- Local build and run procedures
- Container security considerations

### For CI/CD Engineers

Start with **[CICD.md](./CICD.md)**:
- GitHub Actions workflow overview
- Build and generation triggers
- Job dependencies and conditions
- Troubleshooting common issues

### For Pipeline Architects

Read **[PIPELINES.md](./PIPELINES.md)**:
- Complete pipeline architecture
- Data flow between stages
- Build caching strategies
- Error recovery and monitoring

## Quick Start

### Run Locally with Docker

```bash
docker-compose up
```

### Generate PDF Manually

1. Ensure Docker images are built
2. Go to GitHub Actions → "Generate README PDF"
3. Click "Run workflow"
4. Download the PDF artifact

### Build Images Locally

```bash
# Build base image
docker build -f Dockerfile.base -t readme-to-pdf-base .

# Build final image
docker build -f Dockerfile.python \
  --build-arg BASE_IMAGE=readme-to-pdf-base \
  -t readme-to-pdf .
```

### Run Container

```bash
docker run --rm \
  -v $(pwd)/README.md:/app/README.md:ro \
  -e OUTPUT_PDF=my-resume.pdf \
  readme-to-pdf
```

## Key Concepts

### Multi-Stage Build

The Docker setup separates concerns:
- **Base image** (Dockerfile.base): System dependencies, wkhtmltopdf, non-root user
- **Final image** (Dockerfile.python): Python dependencies, application code

**Benefits**: Faster rebuilds, smaller final image, better caching

### Workflow Change Detection

The CI/CD system intelligently detects which components changed and rebuilds only what's necessary:
- Change to `Dockerfile.base` → Rebuild base AND final
- Change to `pyproject.toml` → Rebuild final only
- No relevant changes → Skip rebuild entirely

### Non-Root Execution

All containers run as the unprivileged `appuser` user:
- Enhanced security
- Prevents accidental root operations
- Kubernetes-compliant

## Architecture Overview

```
GitHub Repository
        ↓
[Code Changes]
        ↓
GitHub Actions Workflow
├─ Detect Changes
├─ Build Base Image (if needed)
└─ Build Final Image (if needed)
        ↓
GitHub Container Registry (GHCR)
├─ readme-to-pdf-base:base
├─ readme-to-pdf-base:{sha}
├─ readme-to-pdf:latest
└─ readme-to-pdf:{sha}
        ↓
Manual PDF Generation
├─ Pull image from GHCR
├─ Run container
├─ Generate PDF
└─ Store artifact
```

## File Structure

```
├── docs/
│   ├── README.md           (this file)
│   ├── APP.md             (application documentation)
│   ├── DOCKER.md          (Docker documentation)
│   ├── CICD.md            (CI/CD workflows)
│   └── PIPELINES.md       (detailed pipeline architecture)
├── .github/workflows/
│   ├── build-docker-image.yml   (build workflow)
│   └── generate-pdf.yml         (PDF generation workflow)
├── Dockerfile.base        (base image - system dependencies)
├── Dockerfile.python      (final image - Python app)
├── docker-compose.yml     (local development)
├── main.py               (application code)
├── pyproject.toml        (Python dependencies)
├── style.css             (PDF styling)
└── README.md             (project README)
```

## Common Tasks

### How do I generate a PDF?

1. Via GitHub Actions (manual trigger):
   - Go to Actions → "Generate README PDF"
   - Click "Run workflow"
   - Download artifact after completion

2. Locally with Docker:
   ```bash
   docker-compose up
   ```

3. With custom filename:
   ```bash
   docker run -e OUTPUT_PDF=custom.pdf readme-to-pdf
   ```

### How do I modify the PDF styling?

Edit `style.css` and either:
- Rebuild locally: `docker-compose up --build`
- Or push to trigger workflow and use GitHub Actions

### How do I update Python dependencies?

1. Edit `pyproject.toml`
2. Push changes to trigger workflow
3. Final image will be rebuilt with new dependencies
4. Workflow automatically detects and rebuilds only final image

### How do I add system dependencies?

1. Edit `Dockerfile.base`
2. Push changes to trigger workflow
3. Both base and final images will be rebuilt
4. Workflow automatically detects and rebuilds both

### How do I rebuild everything?

**Via GitHub Actions**:
- Go to Actions → "Build Docker images"
- Click "Run workflow"
- This manually triggers the build even without changes

**Locally**:
```bash
docker-compose up --build --no-cache
```

## Troubleshooting Guide

### "Image not found" error

**Problem**: generate-pdf workflow says image doesn't exist
- **Solution**: Run build-docker-image workflow first

### PDF generation is slow

**Problem**: Takes >5 seconds to generate
- **Solution**: This is normal (wkhtmltopdf is slow). First run after rebuild takes longer.

### Build takes forever

**Problem**: Base image build takes 10+ minutes
- **Solution**: First run with Docker caching disabled. Subsequent runs use cache and are faster.

### Container crashes on startup

**Problem**: "Permission denied" or similar error
- **Solution**: Check README.md exists and volume mount is correct

## Contributing

When making changes to the documentation:
1. Update the relevant doc file (APP.md, DOCKER.md, etc.)
2. Keep consistent formatting and structure
3. Add examples for new features
4. Update this README if adding new documentation

## Additional Resources

- [Markdown documentation](https://daringfireball.net/projects/markdown/)
- [Docker documentation](https://docs.docker.com/)
- [GitHub Actions documentation](https://docs.github.com/en/actions)
- [wkhtmltopdf documentation](https://wkhtmltopdf.org/)

## Support

For issues or questions:
1. Check the relevant documentation file
2. Review the troubleshooting section
3. Check GitHub Actions workflow logs
4. Open an issue on GitHub with error details

---

**Last Updated**: 2026-07-10  
**Version**: 1.0
