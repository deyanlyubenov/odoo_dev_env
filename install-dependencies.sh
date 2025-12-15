#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing Odoo Python dependencies...${NC}"

# Check if Odoo repository exists
if [ ! -d "repositories/odoo" ]; then
    echo -e "${RED}Error: Odoo repository not found!${NC}"
    echo -e "${YELLOW}Please run ./setup-repos.sh first${NC}"
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo -e "${BLUE}Python version: $PYTHON_VERSION${NC}"

# Check if we're in a virtual environment
if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${YELLOW}Warning: Not in a virtual environment!${NC}"
    echo -e "${YELLOW}It's recommended to use a virtual environment${NC}"
    read -p "Do you want to create and activate a virtual environment? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Create virtual environment
        echo -e "${GREEN}Creating virtual environment...${NC}"
        python3 -m venv venv

        echo -e "${GREEN}Virtual environment created!${NC}"
        echo -e "${YELLOW}Please activate it with: source venv/bin/activate${NC}"
        echo -e "${YELLOW}Then run this script again${NC}"
        exit 0
    fi
fi

# Install wheel and setuptools first
echo -e "${BLUE}Installing build dependencies...${NC}"
pip3 install --upgrade pip wheel setuptools

# Install Odoo requirements
if [ -f "repositories/odoo/requirements.txt" ]; then
    echo -e "${BLUE}Installing Odoo requirements from requirements.txt...${NC}"
    pip3 install -r repositories/odoo/requirements.txt
else
    echo -e "${RED}Warning: requirements.txt not found in Odoo repository${NC}"
fi

# Install additional common dependencies for Odoo development
echo -e "${BLUE}Installing additional development dependencies...${NC}"
pip3 install \
    debugpy \
    pylint-odoo \
    watchdog \
    ipython \
    ipdb

# macOS specific: Install PostgreSQL client if needed
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${BLUE}Checking PostgreSQL client tools...${NC}"
    if ! command -v psql &> /dev/null; then
        echo -e "${YELLOW}PostgreSQL client not found${NC}"
        if command -v brew &> /dev/null; then
            echo -e "${BLUE}Installing PostgreSQL client via Homebrew...${NC}"
            brew install postgresql@15
        else
            echo -e "${YELLOW}Please install PostgreSQL client manually or install Homebrew${NC}"
        fi
    else
        echo -e "${GREEN}✓ PostgreSQL client found${NC}"
    fi
fi

echo -e "${GREEN}✓ Python dependencies installed successfully!${NC}"

# Show installed packages
echo -e "${BLUE}Key packages installed:${NC}"
pip3 list | grep -E "(odoo|psycopg|Werkzeug|lxml|Pillow|reportlab)" || true
