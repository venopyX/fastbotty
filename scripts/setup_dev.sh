#!/bin/bash
# Setup development environment for FastBotty
# This script installs all necessary dependencies for local development

set -e  # Exit on error

echo "=========================================="
echo "Setting up FastBotty development environment"
echo "=========================================="
echo ""

# Check Python version
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "🐍 Python version: $PYTHON_VERSION"

# Compare versions without bc (more portable)
MAJOR=$(echo "$PYTHON_VERSION" | cut -d'.' -f1)
MINOR=$(echo "$PYTHON_VERSION" | cut -d'.' -f2)

if [ "$MAJOR" -lt 3 ] || { [ "$MAJOR" -eq 3 ] && [ "$MINOR" -lt 10 ]; }; then
    echo "❌ Python 3.10 or higher is required"
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo ""
    echo "📦 Creating virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
echo ""
echo "📦 Activating virtual environment..."
source .venv/bin/activate

# Upgrade pip
echo ""
echo "📦 Upgrading pip..."
python -m pip install --upgrade pip

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
pip install -r requirements-dev.txt

echo ""
echo "✅ Development environment ready!"
echo ""
echo "Next steps:"
echo "  1. Activate virtual environment: source .venv/bin/activate"
echo "  2. Run tests: make test"
echo "  3. Run linter: make lint"
echo "  4. See all commands: make help"
echo ""
echo "For more information, see docs/CONTRIBUTING.md"
