#!/usr/bin/env python3
"""
Version bumping script for FastBotty.
Supports major, minor, and patch version bumps.
"""

import re
import sys
from pathlib import Path
from typing import Tuple


def parse_version(version_str: str) -> Tuple[int, int, int]:
    """Parse version string into major, minor, patch tuple."""
    match = re.match(r"(\d+)\.(\d+)\.(\d+)", version_str)
    if not match:
        raise ValueError(f"Invalid version format: {version_str}")
    return int(match.group(1)), int(match.group(2)), int(match.group(3))


def bump_version(current_version: str, bump_type: str) -> str:
    """
    Bump version based on type.

    Args:
        current_version: Current version string (e.g., "1.0.2")
        bump_type: Type of bump ("major", "minor", or "patch")

    Returns:
        New version string
    """
    major, minor, patch = parse_version(current_version)

    if bump_type == "major":
        major += 1
        minor = 0
        patch = 0
    elif bump_type == "minor":
        minor += 1
        patch = 0
    elif bump_type == "patch":
        patch += 1
    else:
        raise ValueError(
            f"Invalid bump type: {bump_type}. Must be 'major', 'minor', or 'patch'")

    return f"{major}.{minor}.{patch}"


def update_file(file_path: Path, pattern: str, replacement: str) -> bool:
    """Update a file with regex pattern replacement."""
    if not file_path.exists():
        print(f"⚠️  Warning: {file_path} not found")
        return False

    content = file_path.read_text()
    new_content = re.sub(pattern, replacement, content)

    if content != new_content:
        file_path.write_text(new_content)
        return True
    return False


def update_version(new_version: str) -> None:
    """Update version in all relevant files."""

    files_to_update = {
        Path("pyproject.toml"): (
            r'(?m)^version = ".*"',
            f'version = "{new_version}"'
        ),
        Path("fastbotty/__version__.py"): (
            r'__version__ = ".*"',
            f'__version__ = "{new_version}"'
        ),
        Path("fastbotty/cli/commands.py"): (
            r'@click\.version_option\(version=".*"\)',
            f'@click.version_option(version="{new_version}")'
        ),
        Path("fastbotty/server/app.py"): (
            r'version=".*"',
            f'version="{new_version}"'
        ),
    }

    print(f"Updating version to {new_version}...")
    print()

    for file_path, (pattern, replacement) in files_to_update.items():
        if update_file(file_path, pattern, replacement):
            print(f"✓ Updated {file_path}")
        else:
            print(f"⚠️  No changes in {file_path}")

    print()
    print(f"✓ Version updated to {new_version}")


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Bump version for FastBotty",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python bump_version.py patch        # 1.0.2 -> 1.0.3
  python bump_version.py minor        # 1.0.2 -> 1.1.0
  python bump_version.py major        # 1.0.2 -> 2.0.0
  python bump_version.py --set 1.2.3  # Set to specific version
        """
    )

    parser.add_argument(
        'bump_type',
        nargs='?',
        choices=['major', 'minor', 'patch'],
        help='Type of version bump'
    )
    parser.add_argument(
        '--set',
        dest='set_version',
        metavar='VERSION',
        help='Set to specific version (e.g., 1.2.3)'
    )

    args = parser.parse_args()

    # Validate arguments
    if not args.bump_type and not args.set_version:
        parser.error(
            "Either specify bump type (major/minor/patch) or --set VERSION")

    if args.bump_type and args.set_version:
        parser.error("Cannot specify both bump type and --set")

    # Read current version from pyproject.toml
    pyproject_path = Path("pyproject.toml")
    if not pyproject_path.exists():
        print("Error: pyproject.toml not found")
        sys.exit(1)

    content = pyproject_path.read_text()
    match = re.search(r'version = "([^"]+)"', content)
    if not match:
        print("Error: Could not find version in pyproject.toml")
        sys.exit(1)

    current_version = match.group(1)

    # Calculate new version
    if args.set_version:
        # Validate the version format
        try:
            parse_version(args.set_version)
            new_version = args.set_version
        except ValueError as e:
            print(f"Error: {e}")
            sys.exit(1)
    else:
        new_version = bump_version(current_version, args.bump_type)

    print(f"Current version: {current_version}")
    print(f"New version: {new_version}")
    print()

    update_version(new_version)

    print()
    print("Next steps:")
    print("  1. Review the changes: git diff")
    print("  2. Run tests: make test")
    print("  3. Commit changes: git add -A && git commit -m 'chore: bump version to {}'".format(new_version))
    print(
        f"  4. Create tag: git tag -a v{new_version} -m 'Release v{new_version}'")
    print("  5. Or use: make release version={} notes='Your release notes'".format(
        new_version))


if __name__ == "__main__":
    main()
