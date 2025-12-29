#!/bin/bash
# Test release on TestPyPI before publishing to real PyPI
# This is useful for verifying package builds without affecting production PyPI

set -e  # Exit on error
set -o pipefail

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }

# Get current version
VERSION=$(grep '^version = ' pyproject.toml | cut -d'"' -f2)

echo "=========================================="
echo "Testing release for version $VERSION"
echo "=========================================="
echo ""

# Run tests first
print_info "Running tests..."
if ! python3 -m pytest -v --tb=short; then
    echo "❌ Tests failed! Fix tests before releasing."
    exit 1
fi
print_success "Tests passed"
echo ""

# Build package
print_info "Building package..."
rm -rf dist/
python3 -m build
print_success "Package built"
echo ""

# Show package contents
print_info "Package contents:"
ls -lh dist/
echo ""

# Upload to TestPyPI
print_info "Uploading to TestPyPI..."
echo ""
print_warning "You'll need a TestPyPI API token."
print_info "Get one at: https://test.pypi.org/manage/account/token/"
echo ""

if python3 -m twine upload --repository testpypi dist/*; then
    print_success "Upload complete!"
else
    echo "❌ Upload failed. Check your TestPyPI credentials."
    exit 1
fi

echo ""
echo "=========================================="
print_success "Test release complete!"
echo "=========================================="
echo ""
print_info "Test installation with:"
echo "  pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ fastbotty==$VERSION"
echo ""
print_info "If everything works:"
echo "  1. make release version=$VERSION notes='Your release notes'"
echo "  2. Or: python3 -m twine upload dist/* (to upload to real PyPI)"
