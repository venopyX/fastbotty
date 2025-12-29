# FastBotty Release Commands

## Quick Release (patch version)
```bash
./scripts/quick_fix.sh "Fix HTML parse mode escaping"
```

## Full Release (specify version)
```bash
./scripts/release.sh 1.0.2 "Bug fixes and improvements"
```

## Manual Step-by-Step

### 1. Update version
```bash
./scripts/bump_version.py patch  # or minor, major
# Or set specific version:
./scripts/bump_version.py --set 1.0.2
```

### 2. Update CHANGELOG.md manually
Edit CHANGELOG.md and add release notes

### 3. Run tests
```bash
source .venv/bin/activate
python -m pytest -v
```

### 4. Commit and tag
```bash
git add -A
git commit -m "chore: bump version to 1.0.2"
git tag -a v1.0.2 -m "v1.0.2 - Bug fixes"
```

### 5. Build
```bash
rm -rf dist/
python -m build
```

### 6. Publish to PyPI
```bash
python -m twine upload dist/*
```

### 7. Push to GitHub
```bash
git push origin main
git push origin v1.0.2
```

### 8. Create GitHub release
```bash
gh release create v1.0.2 dist/* \
  --title "v1.0.2" \
  --notes "Bug fixes and improvements"
```

## Test on TestPyPI First
```bash
./scripts/test_release.sh
```

## Using Makefile
```bash
make test          # Run tests
make lint          # Run linter
make format        # Format code
make release version=1.0.2 notes="Bug fixes"
```

## Configure PyPI Token
```bash
# Set environment variables
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-YOUR_API_TOKEN

# Or create ~/.pypirc file
[pypi]
username = __token__
password = pypi-YOUR_API_TOKEN
```

## Emergency Rollback
```bash
# Delete tag locally
git tag -d v1.0.2

# Delete tag remotely
git push --delete origin v1.0.2

# Revert commit
git revert HEAD
git push origin main
```
