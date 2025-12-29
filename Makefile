.PHONY: help install test lint format build publish release clean check version bump-major bump-minor bump-patch pre-release security

help:
	@echo "FastBotty Development Commands:"
	@echo ""
	@echo "Development:"
	@echo "  make install       - Setup development environment"
	@echo "  make test          - Run tests with coverage"
	@echo "  make lint          - Run linter (ruff + mypy)"
	@echo "  make format        - Format code (black + ruff)"
	@echo "  make check         - Run all checks (format + lint + test)"
	@echo "  make security      - Run security audit on dependencies"
	@echo ""
	@echo "Building:"
	@echo "  make build         - Build package"
	@echo "  make clean         - Clean build artifacts"
	@echo ""
	@echo "Versioning:"
	@echo "  make version       - Show current version"
	@echo "  make bump-patch    - Bump patch version (1.0.0 -> 1.0.1)"
	@echo "  make bump-minor    - Bump minor version (1.0.0 -> 1.1.0)"
	@echo "  make bump-major    - Bump major version (1.0.0 -> 2.0.0)"
	@echo ""
	@echo "Release:"
	@echo "  make pre-release   - Run all pre-release checks"
	@echo "  make test-release  - Test release on TestPyPI"
	@echo "  make release       - Full release workflow (use: make release version=1.0.2 notes='Release notes')"
	@echo "  make publish       - Publish to PyPI"
	@echo ""
	@echo "Examples:"
	@echo "  make release version=1.0.2 notes='Bug fixes and improvements'"
	@echo "  make bump-patch"

install:
	@echo "🚀 Setting up development environment..."
	@bash scripts/setup_dev.sh

test:
	@echo "🧪 Running tests with coverage..."
	@python3 -m pytest -v --cov=fastbotty --cov-report=html --cov-report=term
	@echo "✓ Coverage report generated in htmlcov/index.html"

lint:
	@echo "🔍 Running linters..."
	@echo "Running ruff..."
	@python3 -m ruff check fastbotty/
	@echo "Running mypy..."
	@python3 -m mypy fastbotty/
	@echo "✓ Linting complete"

format:
	@echo "✨ Formatting code..."
	@python3 -m black fastbotty/ tests/
	@python3 -m ruff check --fix fastbotty/ tests/
	@echo "✓ Code formatted"

check: format lint test
	@echo "✅ All checks passed!"

security:
	@echo "🔒 Running security audit..."
	@python3 -m pip list --outdated
	@echo "✓ Security audit complete"

build:
	@echo "🔨 Building package..."
	@rm -rf dist/
	@python3 -m build
	@echo "✓ Package built successfully"
	@ls -lh dist/

clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf dist/ build/ *.egg-info .pytest_cache .coverage htmlcov .mypy_cache .ruff_cache
	@find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete
	@echo "✓ Cleaned build artifacts"

version:
	@echo "Current version:"
	@grep '^version = ' pyproject.toml | cut -d'"' -f2

bump-major:
	@echo "🔼 Bumping major version..."
	@python3 scripts/bump_version.py major

bump-minor:
	@echo "🔼 Bumping minor version..."
	@python3 scripts/bump_version.py minor

bump-patch:
	@echo "🔼 Bumping patch version..."
	@python3 scripts/bump_version.py patch

pre-release: check security
	@echo "✅ Pre-release checks complete!"
	@echo "Ready to release version: $$(grep '^version = ' pyproject.toml | cut -d'\"' -f2)"

test-release: pre-release build
	@echo "🧪 Testing release on TestPyPI..."
	@bash scripts/test_release.sh

publish:
	@echo "🚀 Publishing to PyPI..."
	@python3 -m twine upload dist/*

test-pypi:
	@echo "🧪 Publishing to TestPyPI..."
	@python3 -m twine upload --repository testpypi dist/*

release:
ifndef version
	@echo "❌ Error: version parameter required"
	@echo "Usage: make release version=1.0.2 notes='Release notes'"
	@echo "   Or: make release version=1.0.2 notes=path/to/RELEASE_NOTES.md"
	@exit 1
endif
ifndef notes
	@echo "❌ Error: notes parameter required"
	@echo "Usage: make release version=1.0.2 notes='Release notes'"
	@echo "   Or: make release version=1.0.2 notes=path/to/RELEASE_NOTES.md"
	@exit 1
endif
	@bash scripts/release.sh $(version) "$(notes)"
