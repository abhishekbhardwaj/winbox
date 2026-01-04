#!/bin/bash
#
# Version bump helper for winbox
# Usage: ./bump-version.sh [major|minor|patch]
#
# Examples:
#   ./bump-version.sh patch   # 1.0.0 -> 1.0.1
#   ./bump-version.sh minor   # 1.0.0 -> 1.1.0
#   ./bump-version.sh major   # 1.0.0 -> 2.0.0
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WINBOX_FILE="$SCRIPT_DIR/winbox"

# Get current version
CURRENT_VERSION=$(grep -E '^WINBOX_VERSION=' "$WINBOX_FILE" | head -1 | cut -d'"' -f2)

if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Could not find WINBOX_VERSION in winbox script"
    exit 1
fi

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Determine bump type
BUMP_TYPE="${1:-patch}"

case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "Usage: $0 [major|minor|patch]"
        echo ""
        echo "Current version: $CURRENT_VERSION"
        exit 1
        ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

echo "Bumping version: $CURRENT_VERSION -> $NEW_VERSION"

# Update version in winbox script
sed -i.bak "s/^WINBOX_VERSION=\"$CURRENT_VERSION\"/WINBOX_VERSION=\"$NEW_VERSION\"/" "$WINBOX_FILE"
rm -f "$WINBOX_FILE.bak"

echo "Updated winbox to version $NEW_VERSION"
echo ""
echo "Next steps:"
echo "  git add winbox"
echo "  git commit -m \"Bump version to $NEW_VERSION\""
echo "  git push"
echo ""
echo "GitHub Actions will automatically create a release tagged v$NEW_VERSION"
