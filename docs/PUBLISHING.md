# Publishing Guide

Guide for publishing new versions of FastBotty to PyPI 

## Development Setup

Before publishing, ensure you have the development environment set up:

```bash
# Clone the repository
git clone https://github.com/venopyx/fastbotty.git
cd fastbotty

# Setup development environment
make install
# This creates a virtual environment and installs all dependencies

# Or manually:
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
```

## Prerequisites

1. **PyPI account**: https://pypi.org/account/register/
2. **PyPI API token**: https://pypi.org/manage/account/token/
3. **Development tools installed** (from setup above)
4. **GitHub CLI** (optional, for GitHub releases): https://cli.github.com

## Quick Release with Automation

The easiest way to release is using the automation scripts:

### Option 1: Release with inline notes
```bash
make release version=1.0.3 notes="Bug fixes and improvements"
```

### Option 2: Release with notes from file (Recommended)
1. Create a release notes file (e.g., `RELEASE_NOTES.md`):
   ```markdown
   v1.0.3 - Bug Fix Release
   
   - Fixed link formatting in HTML mode
   - Improved error messages
   - Updated documentation
   ```

2. Run the release:
   ```bash
   make release version=1.0.3 notes=RELEASE_NOTES.md
   ```

The script will:
- Read the first line as the release title
- Use subsequent lines as the release notes
- Update version in all files
- Update CHANGELOG.md
- Run tests
- Build package with `python -m build`
- Publish with `python -m twine upload dist/*`
- Push to GitHub and create release

---

## Manual Publishing

If you prefer manual control over each step:

### 1. Update Version

```bash
# Use the bump_version script
python3 scripts/bump_version.py patch    # 1.0.2 -> 1.0.3
python3 scripts/bump_version.py minor    # 1.0.2 -> 1.1.0
python3 scripts/bump_version.py major    # 1.0.2 -> 2.0.0

# Or set specific version
python3 scripts/bump_version.py --set 1.2.3
```

This updates version in:
- `pyproject.toml`
- `fastbotty/__version__.py`
- `fastbotty/cli/commands.py`
- `fastbotty/server/app.py`

### 2. Update CHANGELOG.md

Add entry for the new version:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature

### Fixed
- Bug fix

### Changed
- Change description
```

### 3. Commit Changes

```bash
git add -A
git commit -m "chore: bump version to X.Y.Z"
git tag -a vX.Y.Z -m "vX.Y.Z - Release title"
```

### 4. Build Package

```bash
# Clean previous builds
rm -rf dist/

# Build using python -m build
python3 -m build
```

This creates:
- `dist/fastbotty-X.Y.Z-py3-none-any.whl`
- `dist/fastbotty-X.Y.Z.tar.gz`

### 5. Upload to PyPI

```bash
# Activate your virtual environment first
source .venv/bin/activate

# Upload using twine
python3 -m twine upload dist/*
```

When prompted:
- Username: `__token__`
- Password: `pypi-YOUR_API_TOKEN`

Or use environment variables:
```bash
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-xxx
python3 -m twine upload dist/*
```

### 6. Push to GitHub

```bash
# Push code
git push origin main

# Push tag (required - tags don't push automatically!)
git push origin vX.Y.Z
```

### 7. Create GitHub Release

```bash
# Create GitHub release with artifacts
gh release create vX.Y.Z dist/* \
  --title "vX.Y.Z - Release Title" \
  --notes "Release notes here"
```

Or generate release notes automatically from commits:
```bash
gh release create vX.Y.Z dist/* --generate-notes
```

---

## Using Release Notes File

For better organization, keep your release notes in a file:

**Example `RELEASE_NOTES.md`:**
```markdown
v1.0.3 - Enterprise Automation & Link Formatting

### Fixed
- Link formatting now works correctly in HTML mode
- Fixed import spacing issues

### Added  
- Enhanced Makefile with comprehensive targets
- Production-ready release automation
- Comprehensive documentation

### Changed
- Build process now uses python -m build instead of poetry
- Release process uses python -m twine for publishing
```

Then release with:
```bash
bash scripts/release.sh 1.0.3 RELEASE_NOTES.md
```

Or using Make:
```bash
make release version=1.0.3 notes=RELEASE_NOTES.md
```

---

## GitHub Actions (Automated)

If GitHub Actions is enabled, the workflow will automatically publish when you push a version tag.

### Setup Trusted Publishing (Recommended)

1. Go to https://pypi.org/manage/account/publishing/
2. Add pending publisher:
   - Project: `fastbotty`
   - Owner: `venopyx`
   - Repository: `fastbotty`
   - Workflow: `publish.yml`
   - Environment: `pypi`

3. Create GitHub environment:
   - Go to repo Settings → Environments
   - Create environment named `pypi`

### Publish with GitHub Actions

```bash
# Update version, commit, then:
git tag vX.Y.Z
git push origin main --tags
```

The workflow automatically:
1. Runs tests
2. Builds package with `python -m build`
3. Publishes to PyPI
4. Creates GitHub release

---

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Breaking changes
- **MINOR** (0.X.0): New features, backward compatible
- **PATCH** (0.0.X): Bug fixes, backward compatible

Examples:
- `0.9.0` → `0.9.1` (bug fix)
- `0.9.1` → `0.10.0` (new feature)
- `0.10.0` → `1.0.0` (stable release or breaking change)

---

## Quick Reference

### Automated Release (Recommended)
```bash
# With inline notes
make release version=1.0.3 notes="Bug fixes"

# With notes file (better for multi-line notes)
make release version=1.0.3 notes=RELEASE_NOTES.md
```

### Manual Release
```bash
# 1. Update version
python3 scripts/bump_version.py patch

# 2. Update CHANGELOG.md manually

# 3. Commit and tag
git add -A
git commit -m "chore: bump version to X.Y.Z"
git tag -a vX.Y.Z -m "vX.Y.Z - Release title"

# 4. Build
rm -rf dist/
python3 -m build

# 5. Publish
source .venv/bin/activate
python3 -m twine upload dist/*

# 6. Push
git push origin main
git push origin vX.Y.Z

# 7. Create GitHub release
gh release create vX.Y.Z dist/* --title "vX.Y.Z" --generate-notes
```

---

## Troubleshooting

### "File already exists" error
You cannot overwrite an existing version on PyPI. Bump the version number.

### "Invalid token" error
- Ensure token starts with `pypi-`
- Check token hasn't expired
- Verify token has upload permissions

### "No module named 'build'" error
```bash
pip install -r requirements-dev.txt
# Or install individually:
pip install build twine
```

### Build fails
```bash
pip install --upgrade build setuptools wheel
```

### Test on TestPyPI first
```bash
# Configure TestPyPI
python3 -m twine upload --repository testpypi dist/*

# Test installation
pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ fastbotty
```

---

## Why python -m build?

Using `python -m build` and `python -m twine` for publishing offers:

1. **Standardization**: Uses PEP 517/518 standard build system
2. **Reliability**: Consistent behavior across environments
3. **Simplicity**: Minimal dependencies required
4. **Compatibility**: Works seamlessly in CI/CD environments
