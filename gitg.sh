#!/bin/bash

set -e

# Check if inside a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: Not inside a Git repository" >&2
    exit 1
fi

# Show help if no args or --help
if [ "$1" == "--help" ] || [ -z "$1" ]; then
    echo "Simple git commit & push helper"
    echo "Usage: $(basename $0) <commit-message> [--no-push]"
    echo "By default: stages all files and pushes to remote"
    exit 1
fi

# Get commit message (all args except flags)
message=$(echo "$@" | sed 's/--[^ ]*//g' | xargs)

# Stage all changes
echo "Staging changes..."
git add .

# Commit
echo "Committing: $message"
if ! git commit -m "$message"; then
    echo "Nothing to commit"
    exit 0
fi

# Push by default unless --no-push
if [[ "$*" != *"--no-push"* ]]; then
    echo "Pushing to remote..."
    git push || git push --set-upstream origin "$(git branch --show-current)"
fi

echo "Done!"
