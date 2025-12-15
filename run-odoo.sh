#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f .env ]; then
    source .env
fi

# Check if Odoo repository exists
if [ ! -d "repositories/odoo" ]; then
    echo -e "${RED}Error: Odoo repository not found!${NC}"
    echo -e "${YELLOW}Please run ./setup.sh first${NC}"
    exit 1
fi

# Create data directory
mkdir -p odoo_data

# Build addons path
ADDONS_PATH="repositories/odoo/addons"

# Add odoo/addons if it exists
if [ -d "repositories/odoo/odoo/addons" ]; then
    ADDONS_PATH="$ADDONS_PATH,repositories/odoo/odoo/addons"
fi

# Add enterprise if it exists
if [ -d "repositories/enterprise" ]; then
    ADDONS_PATH="$ADDONS_PATH,repositories/enterprise"
fi

# Add odoo_modules directory
if [ -d "odoo_modules" ]; then
    ADDONS_PATH="$ADDONS_PATH,odoo_modules"
fi

# Update odoo.conf with the correct addons path
sed -i.bak "s|^addons_path =.*|addons_path = $ADDONS_PATH|" odoo.conf && rm -f odoo.conf.bak

echo -e "${GREEN}Starting Odoo 18 Enterprise...${NC}"
echo -e "${BLUE}Addons path: $ADDONS_PATH${NC}"
echo -e "${BLUE}Configuration file: odoo.conf${NC}"
echo -e "${BLUE}Web interface will be available at: http://localhost:${ODOO_PORT:-8069}${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop Odoo${NC}"
echo ""

# Run Odoo
python3 repositories/odoo/odoo-bin \
    --config=odoo.conf \
    "$@"
