# CI/CD Documentation

## Overview

This repository uses **GitHub Actions** for continuous integration and deployment with automated Docker image building and PDF generation.

## Workflow Architecture

The CI/CD system consists of two main workflows:

```
GitHub Workflow System
├── Build Docker Image Workflow (build-docker-image.yml)
│   ├── Detects changes to build files
│   ├── Conditionally builds base image
│   └── Conditionally builds final image
│
└── Generate PDF Workflow (generate-pdf.yml)
    ├── Manual trigger only (workflow_dispatch)
    ├── Pulls pre-built image from GHCR
    └── Generates PDF on-demand
```

## Workflows

### 1. Build Docker Image Workflow

**File**: `.github/workflows/build-docker-image.yml`

**Triggers**:
- **Automatic**: On push when these files change:
  - `Dockerfile.base` → Build base & final images
  - `Dockerfile.python` → Build final image only
  - `pyproject.toml` → Build final image only
- **Manual**: `workflow_dispatch` - Can be triggered anytime from GitHub Actions tab

**Workflow Jobs**:

#### Job 1: detect-changes
- **Purpose**: Determine which components changed
- **Outputs**:
  - `base_changed`: true if Dockerfile.base was modified
  - `final_needed`: true if any build artifact needs rebuild

#### Job 2: build-base-image
- **Condition**: Only if `base_changed == true`
- **Actions**:
  1. Checkout code
  2. Login to GHCR
  3. Build and push base image
- **Tags**:
  - `ghcr.io/0xtaha/readme-to-pdf-base:base` (always latest)
  - `ghcr.io/0xtaha/readme-to-pdf-base:{commit_sha}`
- **Duration**: ~3-5 minutes (first run) or ~1-2 minutes (cached)

#### Job 3: build-final-image
- **Condition**: Only if `final_needed == true` AND (base not changed OR base build succeeded)
- **Ensures**: Final image is never built if base build failed
- **Actions**:
  1. Checkout code
  2. Login to GHCR
  3. Pull base image from registry
  4. Build and push final image
- **Tags**:
  - `ghcr.io/0xtaha/readme-to-pdf:latest`
  - `ghcr.io/0xtaha/readme-to-pdf:{commit_sha}`
- **Duration**: ~1-2 minutes
- **Depends on**: build-base-image (if base changed)

**Job Dependencies**:
```
detect-changes (always runs)
├── build-base-image (if base_changed)
│   └── build-final-image (if final_needed && no base failure)
│
└── build-final-image (if final_needed && base not changed)
```

### 2. Generate PDF Workflow

**File**: `.github/workflows/generate-pdf.yml`

**Triggers**:
- **Manual only**: `workflow_dispatch` - Must be triggered manually from GitHub Actions tab

**Inputs**:
- `output_file` (optional): Custom PDF filename
  - Default: `Taha_Abdelaziz_Sr_DevSecOps_Engineer.pdf`

**Workflow Jobs**:

#### Job 1: generate-pdf
- **Actions**:
  1. Checkout repository
  2. Login to GHCR
  3. Pull pre-built image (`ghcr.io/0xtaha/readme-to-pdf:latest`)
  4. Verify image is available locally
  5. Run container to generate PDF
  6. Mount README.md as read-only
  7. Upload PDF as artifact
- **Duration**: ~30-60 seconds
- **Artifact**: Available for download from Actions run

**Artifact Output**:
- Named: `resume-pdf`
- Path: `{workspace}/{OUTPUT_PDF}`
- Retention: Default (90 days)

## Workflow Execution Flow

### Scenario 1: Update Dockerfile.base

```mermaid
User pushes to Dockerfile.base
        ↓
    Workflow triggered
        ↓
    detect-changes (base_changed=true, final_needed=true)
        ↓
    build-base-image (runs)
        ├─ Success → build-final-image (runs)
        └─ Failure → build-final-image (skipped)
```

### Scenario 2: Update pyproject.toml

```mermaid
User pushes to pyproject.toml
        ↓
    Workflow triggered
        ↓
    detect-changes (base_changed=false, final_needed=true)
        ↓
    build-base-image (skipped)
        ↓
    build-final-image (runs immediately)
```

### Scenario 3: Manual PDF Generation

```mermaid
User clicks "Run workflow" on generate-pdf
        ↓
    Workflow triggered with inputs
        ↓
    generate-pdf job (runs)
        ├─ Pull image from GHCR
        ├─ Run container
        ├─ Generate PDF
        └─ Upload artifact
```

## Action Versions

**Security & Compatibility**:
- `actions/checkout@v4.2.0` - Git operations (Node.js 24 compatible)
- `docker/login-action@v3` - GHCR authentication
- `docker/build-push-action@v6` - Docker image build & push
- `actions/upload-artifact@v4.3.1` - Artifact storage

All versions are pinned to minor versions for reproducibility.

## Environment Variables & Secrets

### Workflow Environment Variables

**build-docker-image.yml**:
```yaml
BASE_IMAGE: ghcr.io/0xtaha/readme-to-pdf-base:base
```

**generate-pdf.yml**:
```yaml
IMAGE_NAME: ghcr.io/0xtaha/readme-to-pdf
IMAGE_TAG: latest
IMAGE_REF: ghcr.io/0xtaha/readme-to-pdf:latest
OUTPUT_PDF: (from input or default)
```

### Secrets Used

- `${{ secrets.GITHUB_TOKEN }}` - Automatically provided for GHCR authentication
  - Scope: Current repository only
  - Permissions: Read contents, write packages

### Available Context Variables

- `${{ github.repository_owner }}` - Resolves to: `0xtaha`
- `${{ github.sha }}` - Current commit SHA (7 chars)
- `${{ github.actor }}` - Authenticated user (workflow runner identity)
- `${{ github.event.inputs.output_file }}` - Manual input parameter

## Failure Handling

### Build Failures

**Base image build fails**:
- Final image build is **automatically skipped**
- Workflow marked as failed
- No broken images pushed to GHCR

**Final image build fails**:
- Only final image is affected
- Base image remains usable
- Previous final image tag still available

### Recovery

**Manual re-run**:
1. Go to Actions tab
2. Select the failed workflow
3. Click "Re-run all jobs"
4. Optionally modify inputs for generate-pdf

**Check logs**:
- Each job has detailed output
- Docker build output visible for debugging
- Git diff results shown in detect-changes

## Permissions & Security

### Workflow Permissions

```yaml
permissions:
  contents: read        # Read repository code
  packages: write       # Push to GHCR
```

### Non-Root Container Execution

- All containers run as `appuser` (UID 1000)
- No `sudo` or privilege escalation
- Aligns with Kubernetes Pod Security Standards

## Monitoring & Observability

### Workflow Status

View in GitHub Actions dashboard:
- Workflow run history
- Individual job status
- Execution duration
- Log output

### Image Registry

Check pushed images:
```bash
# List all tags
gh api /user/packages/container/readme-to-pdf-base/versions

# Check image metadata
docker inspect ghcr.io/0xtaha/readme-to-pdf:latest
```

### PDF Artifact Download

1. Open workflow run
2. Scroll to "Artifacts" section
3. Download `resume-pdf`

## Troubleshooting

### Image Not Found

**Error**: `Unable to find image ghcr.io/0xtaha/readme-to-pdf:latest`
- **Cause**: generate-pdf workflow run before any build workflow
- **Solution**: Run build-docker-image workflow manually first

### Workflow Triggered Unexpectedly

**Check**:
1. What files changed in the push?
2. Do they match the `paths` trigger?
3. Was it a manual dispatch?

### Base Build Succeeded but Final Build Skipped

**This is intentional** if only base changed:
- First run: base builds → final builds
- Subsequent push to Dockerfile.python: final builds → no base rebuild

### Authentication Failures

**Error**: `denied: permission_denied`
- **Cause**: GITHUB_TOKEN doesn't have `packages:write` permission
- **Solution**: Check workflow permissions (auto-granted in most cases)

## Performance Optimization

### Image Caching

**Layer caching**:
- Base image cached across runs
- Rebuilding only Python deps takes ~1-2 minutes
- First full build takes ~5-7 minutes

**Registry caching**:
- GHCR caches base image
- Build-only-if-changed strategy saves build time

### Parallel Execution

- Jobs run in parallel when possible
- detect-changes runs first (output needed by others)
- build-base-image and build-final-image can't run in parallel (dependency)

## CI/CD Best Practices Implemented

✅ **Change detection** - Only rebuild what changed
✅ **Dependency management** - Final image waits for base
✅ **Failure handling** - Skip downstream on upstream failure
✅ **Non-root execution** - Enhanced security
✅ **Version pinning** - Reproducible workflows
✅ **Artifact retention** - Generated PDFs available for download
✅ **Manual override** - Operator can rebuild anytime
✅ **Read-only mounts** - Prevent accidental file modification

## Future Improvements

- Add workflow status badge to README
- Implement Slack notifications on failure
- Add code scanning jobs (Trivy, Snyk)
- Implement rollback strategy for broken images
- Add performance metrics/timings tracking
- Support scheduled/nightly rebuild cycles
