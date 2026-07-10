# Pipelines Documentation

## Overview

The pipeline system manages the complete lifecycle from code push → Docker build → artifact storage → PDF generation. This document explains how data flows through each stage and how to extend or modify pipelines.

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub Repository                       │
│  (Dockerfile.base, Dockerfile.python, pyproject.toml, main.py) │
└────────────────────────┬────────────────────────────────────────┘
                         │ (push event)
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│              GitHub Actions Workflow System                      │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Step 1: Detect Changes                                   │  │
│  │ - Analyze which files changed                            │  │
│  │ - Determine rebuild strategy                             │  │
│  │ - Output: base_changed, final_needed flags               │  │
│  └────────────────┬─────────────────────────────────────────┘  │
│                   ↓                                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Step 2: Build Base Image (if base_changed)              │  │
│  │ - Compile Dockerfile.base                                │  │
│  │ - Install system dependencies & wkhtmltopdf             │  │
│  │ - Create appuser user                                    │  │
│  │ - Push to GHCR (tags: base, sha)                         │  │
│  └────────────────┬─────────────────────────────────────────┘  │
│                   ↓                                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Step 3: Build Final Image (if final_needed)             │  │
│  │ - Wait for base image build (if applicable)              │  │
│  │ - Pull base image from GHCR                              │  │
│  │ - Compile Dockerfile.python                              │  │
│  │ - Install Python dependencies                            │  │
│  │ - Copy application files                                 │  │
│  │ - Push to GHCR (tags: latest, sha)                       │  │
│  └────────────────┬─────────────────────────────────────────┘  │
└────────────────────┼────────────────────────────────────────────┘
                     ↓
        ┌────────────────────────────┐
        │  GitHub Container Registry  │
        │         (GHCR)              │
        │                             │
        │ readme-to-pdf-base:base    │
        │ readme-to-pdf-base:{sha}   │
        │ readme-to-pdf:latest       │
        │ readme-to-pdf:{sha}        │
        └────────┬───────────────────┘
                 │ (pull on demand)
                 ↓
        ┌────────────────────────────┐
        │   Generate PDF Workflow     │
        │   (manual trigger)          │
        │                             │
        │ 1. Pull latest image        │
        │ 2. Run container            │
        │ 3. Generate PDF             │
        │ 4. Upload artifact          │
        └────────┬───────────────────┘
                 ↓
        ┌────────────────────────────┐
        │  GitHub Artifacts Storage   │
        │  (resume-pdf)               │
        │                             │
        │ {OUTPUT_PDF}               │
        └────────────────────────────┘
```

## Pipeline Stages

### Stage 1: Detection

**Trigger**: Code push to repository

**Input**: Git diff (before → after commit)

**Process**:
```bash
# Check which files changed
git diff --name-only $before $after

# Set flags based on changes
if grep -q 'Dockerfile.base'; then
  base_changed=true
  final_needed=true
fi
if grep -q 'Dockerfile.python'; then
  final_needed=true
fi
if grep -q 'pyproject.toml'; then
  final_needed=true
fi
```

**Output**: 
- `base_changed`: Boolean flag
- `final_needed`: Boolean flag

**Exit Condition**: If neither flag is true, pipeline stops (no rebuild needed)

### Stage 2: Base Image Build

**Trigger**: `base_changed == true`

**Input**:
- `Dockerfile.base` (immutable from repo)
- System dependencies list
- Playwright + Chromium browser version (installed during final image build or at build time)

**Process**:
```
Stage 2a: Prepare Environment
- Checkout repository
- Authenticate with GHCR

Stage 2b: Build Image
- FROM python:3.14-slim
- RUN apt-get install (Chromium dependencies) and ensure Playwright browsers are available
- RUN groupadd/useradd (appuser)
- WORKDIR /app
- RUN chown (appuser:appuser)

Stage 2c: Push Image
- Tag: ghcr.io/0xtaha/readme-to-pdf-base:base
- Tag: ghcr.io/0xtaha/readme-to-pdf-base:{sha}
- Push to GHCR
```

**Duration**: 
- First run: 5-7 minutes (download all layers)
- Subsequent: 2-3 minutes (cache hits)

**Output**:
- Base image pushed to GHCR
- Build artifacts (layers) cached in runner

**Failure Handling**:
- If build fails: Pipeline stops
- Final image build automatically skipped
- No broken images in registry

### Stage 3: Final Image Build

**Trigger**: `final_needed == true` AND (base_changed == false OR base build succeeded)

**Dependencies**:
- Base image must exist in GHCR (pulled from registry)
- If base_changed, must wait for build-base-image to complete

**Input**:
- `Dockerfile.python` (uses ARG BASE_IMAGE)
- `pyproject.toml` (dependency versions)
- `main.py`, `style.css` (application files)
- Base image from GHCR

**Process**:
```
Stage 3a: Prepare Environment
- Checkout repository
- Authenticate with GHCR

Stage 3b: Pull Base Image
- docker pull ghcr.io/0xtaha/readme-to-pdf-base:base
- Store locally for build context

Stage 3c: Build Image
- FROM ${BASE_IMAGE}
- COPY (pyproject.toml, main.py, style.css)
- RUN python -m pip install uv
- RUN uv install (from pyproject.toml)
- RUN chown (appuser:appuser)
- USER appuser
- CMD ["python", "main.py"]

Stage 3d: Push Image
- Tag: ghcr.io/0xtaha/readme-to-pdf:latest
- Tag: ghcr.io/0xtaha/readme-to-pdf:{sha}
- Push to GHCR
```

**Duration**: 1-2 minutes (base already built)

**Output**:
- Final image pushed to GHCR
- `latest` tag updated
- Previous image remains available via SHA tag

### Stage 4: Manual PDF Generation

**Trigger**: User clicks "Run workflow" on generate-pdf workflow

**Inputs**:
- `output_file` (optional): Custom PDF filename

**Process**:
```
Stage 4a: Environment Setup
- Checkout repository
- Authenticate with GHCR

Stage 4b: Pull Image
- docker pull ghcr.io/0xtaha/readme-to-pdf:latest
- Verify image available locally

Stage 4c: Run Container
- Mount: README.md (read-only) → /app/README.md
- Mount: WORKSPACE → /app
- Environment: OUTPUT_PDF={filename}
- Execute: python main.py (as appuser)

Stage 4d: Generate PDF
- Inside container:
  1. Read README.md
  2. Read style.css
  3. Convert markdown → HTML
  4. Apply CSS styling
  5. Render HTML → PDF (wkhtmltopdf)
  6. Write output file

Stage 4e: Store Artifact
- Upload PDF to GitHub Artifacts
- Retention: 90 days (default)
- Name: resume-pdf
- Available for download
```

**Duration**: 30-60 seconds

**Output**:
- PDF file in GitHub Artifacts
- Link provided in workflow run

**User Interaction**:
1. Navigate to Actions → Generate README PDF
2. Click "Run workflow"
3. (Optional) Override output filename
4. Wait for completion
5. Download artifact

## Data Flow & Caching

### Build Caching Strategy

**Layer Cache**:
```
Layer 1: Base OS       (cached forever - rarely changes)
Layer 2: Dependencies  (cached 24 hours - with fallback)
Layer 3: Application   (cached per build - always rebuilt)
```

**Build Cache Efficiency**:
- If only pyproject.toml changes: Layer 1-2 reused, only Layer 3 rebuilt
- If Dockerfile.base changes: All layers in base rebuilt, final image rebuilt
- If only main.py changes: Layers 1-2 reused

**GitHub Actions Layer Caching**:
- Docker layer cache stored in GHCR
- Persists for 24 hours
- Key: `type=gha` in build-push-action

### Image Tagging Strategy

**Immutable by SHA**:
```
ghcr.io/0xtaha/readme-to-pdf-base:a1b2c3d (specific commit)
```
- Never changes
- Used for rollback or specific version pinning
- Preserved forever

**Mutable Latest**:
```
ghcr.io/0xtaha/readme-to-pdf:latest
```
- Updated on every build
- Points to most recent stable version
- Used by generate-pdf workflow

**Benefits**:
- Automatic rollback via SHA tags
- CI always uses latest (simple to manage)
- No orphaned images

## Pipeline Conditions & Branching

### Decision Tree

```
┌─ Dockerfile.base changed?
│  ├─ YES → base_changed=true, final_needed=true
│  └─ NO  → base_changed=false
│
├─ Dockerfile.python changed?
│  ├─ YES → final_needed=true
│  └─ NO  → (check next)
│
└─ pyproject.toml changed?
   ├─ YES → final_needed=true
   └─ NO  → final_needed=false (no rebuild)

THEN:

If base_changed=true:
  → Run build-base-image

If final_needed=true:
  Check: base_changed=false OR base build succeeded?
  → Run build-final-image
```

## Environment & Secrets Propagation

### Secrets (provided by GitHub)

```yaml
${{ secrets.GITHUB_TOKEN }}
├─ Used for: GHCR authentication
├─ Scope: Current repository
├─ Permissions: contents:read, packages:write
└─ Auto-provided: No configuration needed
```

### Environment Variables (workflow-defined)

**In build-docker-image.yml**:
```yaml
jobs:
  build-final-image:
    env:
      BASE_IMAGE: ghcr.io/${{ github.repository_owner }}/readme-to-pdf-base:base
```

**In generate-pdf.yml**:
```yaml
jobs:
  generate-pdf:
    env:
      OUTPUT_PDF: ${{ github.event.inputs.output_file || 'Taha_Abdelaziz_Sr_DevSecOps_Engineer.pdf' }}
      IMAGE_REF: ghcr.io/0xtaha/readme-to-pdf:latest
```

**Propagation**:
- Secrets → Available in all steps
- Env variables → Available in run steps as `$VAR` or `${{ env.VAR }}`
- Build args → Passed to docker build context

## Error Recovery & Rollback

### Build Failure Recovery

**Scenario**: Final image build fails

**Status**:
- Base image: ✓ OK (unchanged)
- Final image: ✗ Failed

**Options**:
1. **Fix & re-push**: Correct code and push again
2. **Manual rebuild**: Click "Re-run all jobs" on workflow
3. **Rollback**: Use previous SHA tag image

**Preventing Cascade**:
- generate-pdf workflow checks image exists before running
- Manual verification step prevents broken image usage

### Workflow Re-runs

**Full re-run**:
```
GitHub UI → Actions → Select run → Re-run all jobs
```

**Partial re-run** (failed job only):
```
GitHub UI → Actions → Select run → Re-run failed jobs
```

**Affects**:
- Re-runs all jobs from scratch
- Uses fresh checkout (latest code)
- Rebuilds all layers

## Monitoring Pipeline Health

### Workflow Metrics

**Available in GitHub Actions Dashboard**:
- Execution time per job
- Success/failure rate
- Trend analysis (weekly)

**Check image health**:
```bash
# View recent builds
gh api /user/packages/container/readme-to-pdf/versions

# Inspect image
docker inspect ghcr.io/0xtaha/readme-to-pdf:latest
```

### Common Metrics to Track

- **Build time**: Should be <2 min for final image (cached)
- **Cache hit rate**: Higher % = more efficient builds
- **Failure rate**: Should be 0 (detect broken changes early)
- **Artifact generation**: Should succeed 100% if image exists

## Advanced Configuration

### Custom Build Arguments

To add new build-time arguments:

1. **In Dockerfile.python**:
```dockerfile
ARG CUSTOM_ARG=default_value
RUN echo "Using: $CUSTOM_ARG"
```

2. **In workflow**:
```yaml
build-args: |
  BASE_IMAGE=${{ env.BASE_IMAGE }}
  CUSTOM_ARG=custom_value
```

### Conditional Job Execution

To add new conditionals:

```yaml
jobs:
  new-job:
    if: |
      needs.detect-changes.outputs.some_condition == 'true' &&
      needs.previous-job.result == 'success'
```

## Performance Tuning

### Layer Caching Optimization

**Best practices**:
1. Place stable steps first (base image)
2. Place frequently-changing steps last (code copy)
3. Minimize RUN commands (combine with &&)
4. Use .dockerignore to exclude unnecessary files

### Build Parallelization

**Currently**:
- detect-changes: serial
- build-base-image: can't parallelize (no other jobs depend on it yet)
- build-final-image: waits for base

**Improvement opportunities**:
- Run linting jobs in parallel with build
- Run security scans in parallel with build

## Future Enhancements

- Add smoke test job after build
- Implement image security scanning (Trivy)
- Add changelog generation from commits
- Implement staged rollout (canary deployment)
- Add performance benchmarking
- Integrate with Slack for notifications
