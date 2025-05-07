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

# Add all changes
echo "Adding all changes..."
git add .

# Commit with the provided message
echo "Committing with message: $1"
git commit -m "$1"

# Push if --push flag is provided
if [ "$2" = "--push" ] || [ "$3" = "--push" ]; then
    echo "Pushing to remote..."
    git push || {
        echo "Error: git push failed. Check remote or pull first." >&2
        exit 1
    }
fi

echo "Done!"
