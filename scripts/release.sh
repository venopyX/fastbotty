#!/bin/bash
# Enterprise-grade release workflow for FastBotty
# Features:
# - Comprehensive pre-release validation
# - Automatic rollback on failure
# - Branch protection checks
# - Tool dependency validation
# - Support for release notes from file

set -e  # Exit on error
set -o pipefail  # Exit on pipe failure

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_step() { echo -e "${BLUE}▶ $1${NC}"; }

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate required tools
validate_tools() {
    print_step "Validating required tools..."
    
    local missing_tools=()
    
    if ! command_exists python3; then
        missing_tools+=("python3")
    fi
    
    if ! command_exists git; then
        missing_tools+=("git")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo "Please install the missing tools and try again."
        exit 1
    fi
    
    # Check for build and twine (not poetry)
    if ! python3 -c "import build" 2>/dev/null; then
        print_warning "build module not found. Install with: pip install build"
        missing_tools+=("build")
    fi
    
    if ! command_exists twine; then
        print_warning "twine not found. Install with: pip install twine"
        missing_tools+=("twine")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing build tools. Install with:"
        echo "  pip install build twine"
        exit 1
    fi
    
    print_success "All required tools are available"
}

# Function to check git status
check_git_status() {
    print_step "Checking git status..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        print_error "Uncommitted changes detected"
        echo "Please commit or stash your changes before releasing."
        git status --short
        exit 1
    fi
    
    # Check current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    print_info "Current branch: $CURRENT_BRANCH"
    
    # Warn if not on main/master
    if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
        print_warning "You're not on main/master branch"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Release cancelled"
            exit 0
        fi
    fi
    
    print_success "Git status is clean"
}

# Function to validate version format
validate_version() {
    local version=$1
    if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format: $version"
        echo "Version must be in format: X.Y.Z (e.g., 1.0.2)"
        exit 1
    fi
}

# Function to check if tag already exists
check_tag_exists() {
    local version=$1
    if git rev-parse "v$version" >/dev/null 2>&1; then
        print_error "Tag v$version already exists"
        echo "Use a different version or delete the existing tag:"
        echo "  git tag -d v$version"
        exit 1
    fi
}

# Main release function
main() {
    if [ -z "$1" ]; then
        print_error "Usage: ./release.sh <version> [release_notes_or_file]"
        echo "Examples:"
        echo "  ./release.sh 1.0.2 'Bug fixes for HTML parse mode'"
        echo "  ./release.sh 1.0.2 path/to/RELEASE_NOTES.md"
        exit 1
    fi
    
    NEW_VERSION=$1
    RELEASE_INPUT=${2:-"Release $NEW_VERSION"}
    
    # Check if release input is a file
    if [ -f "$RELEASE_INPUT" ]; then
        print_info "Reading release notes from file: $RELEASE_INPUT"
        # Read first line as title, rest as notes
        RELEASE_TITLE=$(head -n 1 "$RELEASE_INPUT")
        RELEASE_NOTES=$(tail -n +2 "$RELEASE_INPUT" | sed '/^$/d')  # Skip empty lines
    elif [[ "$RELEASE_INPUT" == *.md ]] || [[ "$RELEASE_INPUT" == *.txt ]] || [[ "$RELEASE_INPUT" == *.rst ]] || \
         [[ "$RELEASE_INPUT" == *"/"*.md ]] || [[ "$RELEASE_INPUT" == *"/"*.txt ]] || [[ "$RELEASE_INPUT" == *"/"*.rst ]]; then
        # Input looks like a file path (ends with common extension or contains path + extension) but file doesn't exist
        print_error "File not found: $RELEASE_INPUT"
        echo "Please provide a valid file path or use literal text for release notes."
        echo "Examples:"
        echo "  ./release.sh 1.0.2 'Bug fixes for HTML parse mode'"
        echo "  ./release.sh 1.0.2 RELEASE_NOTES.md"
        echo "  ./release.sh 1.0.2 path/to/RELEASE_NOTES.md"
        exit 1
    else
        RELEASE_TITLE="Release $NEW_VERSION"
        RELEASE_NOTES="$RELEASE_INPUT"
    fi
    
    echo "=========================================="
    echo "Releasing FastBotty v$NEW_VERSION"
    echo "=========================================="
    echo ""
    
    # Step 0: Validate environment
    validate_tools
    check_git_status
    validate_version "$NEW_VERSION"
    check_tag_exists "$NEW_VERSION"
    
    # Step 1: Update version in all files
    print_step "Step 1: Updating version numbers..."
    python3 scripts/bump_version.py --set "$NEW_VERSION" || {
        print_error "Failed to update version"
        exit 1
    }
    print_success "Version numbers updated"
    echo ""
    
    # Step 2: Update CHANGELOG.md
    print_step "Step 2: Updating CHANGELOG.md..."
    TODAY=$(date +%Y-%m-%d)
    
    # Create new changelog entry with formatted notes
    NEW_ENTRY="## [$NEW_VERSION] - $TODAY

### Changes
$RELEASE_NOTES

"
    
    # Use Python to insert the entry
    python3 << EOF
import re

with open('CHANGELOG.md', 'r') as f:
    content = f.read()

# Find the first version header and insert before it
new_entry = """$NEW_ENTRY"""
pattern = r'(## \[\d+\.\d+\.\d+\])'
new_content = re.sub(pattern, new_entry + r'\1', content, count=1)

with open('CHANGELOG.md', 'w') as f:
    f.write(new_content)
EOF
    
    print_success "CHANGELOG.md updated"
    echo ""
    
    # Step 3: Run tests
    print_step "Step 3: Running tests..."
    if [ -d ".venv" ]; then
        source .venv/bin/activate
    fi
    
    if ! python3 -m pytest -v --tb=short; then
        print_error "Tests failed!"
        echo ""
        print_warning "Rolling back changes..."
        git checkout -- .
        exit 1
    fi
    print_success "Tests passed"
    echo ""
    
    # Step 4: Run linters
    print_step "Step 4: Running linters..."
    if ! python3 -m ruff check fastbotty/; then
        print_warning "Ruff found issues (continuing anyway)"
    fi
    print_success "Linting complete"
    echo ""
    
    # Step 5: Git operations
    print_step "Step 5: Committing changes..."
    git add -A
    git commit -m "chore: bump version to $NEW_VERSION

$RELEASE_NOTES" || {
        print_error "Failed to commit changes"
        exit 1
    }
    print_success "Changes committed"
    echo ""
    
    print_step "Step 6: Creating git tag..."
    git tag -a "v$NEW_VERSION" -m "$RELEASE_TITLE" || {
        print_error "Failed to create tag"
        exit 1
    }
    print_success "Tag v$NEW_VERSION created"
    echo ""
    
    # Step 7: Build package with python -m build
    print_step "Step 7: Building package..."
    rm -rf dist/
    if ! python3 -m build; then
        print_error "Build failed!"
        print_warning "Rolling back..."
        git tag -d "v$NEW_VERSION"
        git reset --hard HEAD~1
        exit 1
    fi
    print_success "Package built"
    echo ""
    
    # Step 8: Show what will be published
    print_info "Package contents:"
    ls -lh dist/
    echo ""
    
    # Step 9: Confirmation before publishing
    print_warning "About to publish to PyPI and push to GitHub"
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Release cancelled"
        print_info "To continue later:"
        echo "  1. python -m twine upload dist/*"
        echo "  2. git push origin $CURRENT_BRANCH"
        echo "  3. git push origin v$NEW_VERSION"
        exit 0
    fi
    
    # Step 10: Upload to PyPI with twine
    print_step "Step 8: Uploading to PyPI..."
    print_info "Using: python -m twine upload dist/*"
    if ! python3 -m twine upload dist/*; then
        print_error "Failed to publish to PyPI"
        print_warning "Package built but not published"
        print_info "To publish later: python -m twine upload dist/*"
        exit 1
    fi
    print_success "Published to PyPI"
    echo ""
    
    # Step 11: Push to GitHub
    print_step "Step 9: Pushing to GitHub..."
    git push origin "$CURRENT_BRANCH" || {
        print_warning "Failed to push branch (but package is published)"
    }
    git push origin "v$NEW_VERSION" || {
        print_warning "Failed to push tag (but package is published)"
    }
    print_success "Pushed to GitHub"
    echo ""
    
    # Step 12: Create GitHub release
    print_step "Step 10: Creating GitHub release..."
    if command_exists gh; then
        if gh release create "v$NEW_VERSION" dist/* \
            --title "$RELEASE_TITLE" \
            --notes "$RELEASE_NOTES"; then
            print_success "GitHub release created"
        else
            print_warning "Failed to create GitHub release"
        fi
    else
        print_warning "GitHub CLI not installed. Skipping release creation."
        print_info "Install with: brew install gh (macOS) or visit https://cli.github.com"
        print_info "Or create release manually at: https://github.com/venopyx/fastbotty/releases/new?tag=v$NEW_VERSION"
    fi
    echo ""
    
    echo "=========================================="
    print_success "Release v$NEW_VERSION complete!"
    echo "=========================================="
    echo ""
    echo "📦 Package: https://pypi.org/project/fastbotty/$NEW_VERSION/"
    echo "🐙 GitHub: https://github.com/venopyx/fastbotty/releases/tag/v$NEW_VERSION"
    echo ""
    echo "Next steps:"
    echo "  1. Verify package on PyPI: pip install --upgrade fastbotty"
    echo "  2. Test installation: fastbotty --version"
    echo "  3. Share release announcement"
}

# Run main function
main "$@"
