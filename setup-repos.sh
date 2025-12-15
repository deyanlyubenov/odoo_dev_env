#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment variables
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and configure your GitHub token${NC}"
    exit 1
fi

source .env

# Verify GitHub token for private repos
if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "your_github_token_here" ]; then
    echo -e "${RED}Error: GITHUB_TOKEN not configured in .env file${NC}"
    echo -e "${YELLOW}Please set your GitHub personal access token in .env${NC}"
    exit 1
fi

# Create directories
echo -e "${GREEN}Creating directory structure...${NC}"
mkdir -p repositories
mkdir -p odoo_modules

# Read repositories from repos.json
REPOS=$(cat repos.json | python3 -c "
import sys, json
data = json.load(sys.stdin)
for repo in data['repositories']:
    if repo.get('enabled', True):
        print(f\"{repo['name']}|{repo['url']}|{repo['branch']}|{repo['type']}|{repo.get('requires_auth', False)}\")
")

# Clone or update repositories
while IFS='|' read -r name url branch type requires_auth; do
    REPO_PATH="repositories/$name"

    if [ -d "$REPO_PATH" ]; then
        echo -e "${YELLOW}Repository $name already exists, updating...${NC}"
        cd "$REPO_PATH"

        # Check if auth is required and configure git credential helper
        if [ "$requires_auth" = "True" ]; then
            # Configure git to use the token for this repository
            git config credential.helper "!f() { echo \"username=x-access-token\"; echo \"password=$GITHUB_TOKEN\"; }; f"
        fi

        git fetch origin
        git checkout "$branch"
        git pull origin "$branch"
        cd ../..
    else
        echo -e "${GREEN}Cloning $name...${NC}"

        if [ "$requires_auth" = "True" ]; then
            # Use HTTPS with token for cloning private repos
            HTTPS_URL=$(echo "$url" | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
            git clone -b "$branch" "https://x-access-token:${GITHUB_TOKEN}@github.com/${HTTPS_URL#https://github.com/}.git" "$REPO_PATH"
        else
            git clone -b "$branch" "$url" "$REPO_PATH"
        fi
    fi

    echo -e "${GREEN}✓ Repository $name ready${NC}"
done <<< "$REPOS"

echo -e "${GREEN}All repositories cloned/updated successfully!${NC}"
