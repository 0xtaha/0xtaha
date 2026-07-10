# Docker Documentation

## Architecture Overview

The application uses a **multi-stage Docker build** strategy to optimize image size, build time, and maintainability:

```
Dockerfile.base (Stage 1)
├── Base: python:3.14-slim
├── Install: System dependencies & wkhtmltopdf
├── Create: Non-root user 'appuser'
└── Tag: ghcr.io/0xtaha/readme-to-pdf-base:{base|sha}

Dockerfile.python (Stage 2)
├── From: readme-to-pdf-base
├── Copy: Application files (pyproject.toml, main.py, style.css)
├── Install: UV package manager & Python dependencies
├── User: Switch to 'appuser'
└── Tag: ghcr.io/0xtaha/readme-to-pdf:{latest|sha}
```

## Dockerfiles

### Dockerfile.base

**Purpose**: Prepare the runtime environment with system-level dependencies

**Key Features**:
- Minimal Python image (3.14-slim)
- wkhtmltopdf and all required system libraries
- Non-root user creation for security
- Optimized layer caching

**Dependencies Installed**:
```
System:
- wget (for downloading wkhtmltopdf)
- libxrender1, libxext6, libfontconfig1 (graphics rendering)
- fontconfig, xfonts-75dpi, xfonts-base (font support)
- libjpeg62-turbo, libpng16-16 (image support)
- libx11-6, libxcb1 (X11 libraries)

Application:
- wkhtmltopdf 0.12.6.1-3 (HTML to PDF conversion)
```

**User Context**:
- `appuser` (UID/GID: dynamically assigned)
- System user with no shell access
- /app directory owned by appuser

### Dockerfile.python

**Purpose**: Build the application layer with Python dependencies

**Key Features**:
- Builds on top of base image
- UV for fast, reliable Python dependency installation
- Minimal image size (only application code, no build tools)
- Non-root execution

**Build Arguments**:
- `BASE_IMAGE` - Registry URL of base image (passed from workflow)

**Build Process**:
1. Copy project files (pyproject.toml, main.py, style.css)
2. Install UV package manager
3. Install Python dependencies from pyproject.toml
4. Set appuser as default runtime user
5. Define CMD to run main.py

## Image Organization

### Image Tags

All images are pushed to GitHub Container Registry (GHCR):

**Base Image**:
- `ghcr.io/0xtaha/readme-to-pdf-base:base` - Latest stable base (always updated)
- `ghcr.io/0xtaha/readme-to-pdf-base:{sha}` - Specific commit SHA

**Final Image**:
- `ghcr.io/0xtaha/readme-to-pdf:latest` - Latest stable version
- `ghcr.io/0xtaha/readme-to-pdf:{sha}` - Specific commit SHA

### Image Sizes

Typical sizes (compressed):
- Base image: ~500-600 MB
- Final image: ~600-700 MB (includes Python deps)

## Building Locally

### With Docker Compose

```bash
# Build and run with default settings
docker-compose up

# Rebuild images without cache
docker-compose up --build --no-cache

# Run with custom output filename
docker-compose run readme-to-pdf python main.py
```

The compose file automatically:
- Mounts README.md as read-only
- Sets OUTPUT_PDF environment variable
- Maps working directory

### With Docker CLI

**Build base image**:
```bash
docker build -f Dockerfile.base -t readme-to-pdf-base .
```

**Build final image**:
```bash
docker build -f Dockerfile.python \
  --build-arg BASE_IMAGE=readme-to-pdf-base \
  -t readme-to-pdf .
```

**Run the container**:
```bash
docker run --rm \
  -v $(pwd)/README.md:/app/README.md:ro \
  -e OUTPUT_PDF=my-resume.pdf \
  readme-to-pdf
```

## Security Considerations

### Non-Root User Execution

**Why**: Reduces attack surface and prevents accidental root operations
- Containerized applications should run as non-root
- Limits damage in case of container breakout
- Required for many Kubernetes security policies

**Implementation**:
1. Base image creates `appuser` system user
2. Base image sets /app ownership to appuser
3. Python image runs as appuser before CMD

**Verification**:
```bash
# Check user in running container
docker run --rm readme-to-pdf id

# Output should show:
# uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)
```

### Volume Mounting

**Read-Only README.md**: 
- Prevents accidental modification of source file
- Defined in docker-compose.yml as `:ro` flag

**Output Directory**:
- PDF output is written to /app (mounted)
- Accessible from host after container completes

## Multi-Stage Build Benefits

### Size Optimization
- Build tools (UV) not included in final image
- Only runtime dependencies ship to registry
- Reduces storage and transfer costs

### Build Speed
- Base image cached between builds
- Rebuilding only Python deps is faster
- Triggered independently by changes

### Maintainability
- Clear separation of concerns
- Easier to debug layer-by-layer
- Simpler dependency updates

## Registry Configuration

### GitHub Container Registry (GHCR)

**Authentication**:
- Workflows use `${{ secrets.GITHUB_TOKEN }}`
- Automatically authenticated in GitHub Actions
- Manual push requires: `gh auth login`

**Namespace**: `ghcr.io/0xtaha/` (organization-level)

**Access**:
- Public by default (configurable in settings)
- Pull: No authentication required
- Push: Requires GitHub actor authentication

## Troubleshooting

### Build Failures

**Issue**: `docker: build-push-action@v6: unable to resolve action`
- **Solution**: Update action version to available tag

**Issue**: `wkhtmltopdf: error while loading shared libraries`
- **Solution**: Verify all system libraries installed in base image

### Runtime Failures

**Issue**: `Permission denied` when writing PDF
- **Solution**: Check appuser ownership of /app directory

**Issue**: `No such file or directory: README.md`
- **Solution**: Ensure README.md is mounted in docker-compose.yml

### Performance Issues

**Issue**: Slow PDF generation
- **Solution**: Pre-cache base image to avoid rebuilds
- **Solution**: Use smaller CSS or optimize images in README

## Container Orchestration

### Kubernetes Deployment

Example snippet:
```yaml
spec:
  containers:
  - name: readme-to-pdf
    image: ghcr.io/0xtaha/readme-to-pdf:latest
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
      readOnlyRootFilesystem: true
    volumeMounts:
    - name: readme
      mountPath: /app/README.md
      subPath: README.md
      readOnly: true
    - name: tmp
      mountPath: /tmp
```

The non-root user ensures Pod Security Standards compliance.

## Future Improvements

- Slim down base image by removing unnecessary libraries
- Implement image signing for supply chain security
- Add health checks (liveness/readiness probes)
- Cache Python dependencies in layer for faster builds
- Support ARM64 architecture
