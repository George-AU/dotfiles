#!/bin/bash

# Exit on any error
set -e

# Check if inside a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: Not inside a Git repository" >&2
    exit 1
fi

# Check if a commit message is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a commit message" >&2
    echo "Usage: $0 <commit-message> [--pull] [--push]" >&2
    exit 1
fi

# Check for clean working directory
if ! git diff-index --quiet HEAD -- || [ -n "$(git status --porcelain)" ]; then
    echo "Working directory is not clean. Stashing changes..."
    git stash push -u
    STASHED=true
else
    STASHED=false
fi

# Pull with rebase if --pull flag is provided
if [ "$2" = "--pull" ] || [ "$3" = "--pull" ]; then
    echo "Pulling latest changes from remote..."
    git pull --rebase || {
        echo "Error: git pull failed. Resolve conflicts manually." >&2
        if [ "$STASHED" = true ]; then
            git stash pop
        fi
        exit 1
    }
fi

# Restore stashed changes if any
if [ "$STASHED" = true ]; then
    echo "Restoring stashed changes..."
    git stash pop
fi

# Check if there are changes to commit
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes to commit. Working tree is clean."
    exit 0
fi

# Add all changes, including this script
echo "Adding all changes, including this script..."
git add "$0"  # Explicitly stage this script
git add .

# Commit with the provided message
echo "Committing with message: $1"
if ! git commit -m "$1" >/dev/null 2>&1; then
    echo "No changes to commit. Working tree is clean."
else
    echo "Commit created successfully."
fi

# Push if --push flag is provided
if [ "$2" = "--push" ] || [ "$3" = "--push" ]; then
    echo "Pushing to remote..."
    # Check if upstream is set
    if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        echo "No upstream branch set. Setting upstream to origin/$(git rev-parse --abbrev-ref HEAD)..."
        git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD) || {
            echo "Error: Failed to set upstream and push. Check remote configuration." >&2
            exit 1
        }
    else
        git push || {
            echo "Error: git push failed. Check remote or pull first." >&2
            exit 1
        }
    fi
fi

echo "Done!"
