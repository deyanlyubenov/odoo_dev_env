#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         Odoo 18 Enterprise Development Setup              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from .env.example...${NC}"
    cp .env.example .env
    echo -e "${RED}⚠ IMPORTANT: Please edit .env and add your GitHub token!${NC}"
    echo -e "${YELLOW}You can generate a token at: https://github.com/settings/tokens${NC}"
    echo -e "${YELLOW}Required scope: repo (Full control of private repositories)${NC}"
    echo ""
    read -p "Press Enter after you've configured .env file..."
fi

# Check Docker
echo -e "${BLUE}Checking Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed!${NC}"
    echo -e "${YELLOW}Please install Docker Desktop from: https://www.docker.com/products/docker-desktop${NC}"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker is not running!${NC}"
    echo -e "${YELLOW}Please start Docker Desktop${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is ready${NC}"

# Check Python
echo -e "${BLUE}Checking Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is not installed!${NC}"
    exit 1
fi
PYTHON_VERSION=$(python3 --version | awk '{print $2}')
echo -e "${GREEN}✓ Python $PYTHON_VERSION found${NC}"

# Start PostgreSQL
echo -e "${BLUE}Starting PostgreSQL database...${NC}"
docker-compose up -d postgres
echo -e "${GREEN}✓ PostgreSQL started${NC}"

# Wait for PostgreSQL to be ready
echo -e "${YELLOW}Waiting for PostgreSQL to be ready...${NC}"
sleep 5

# Clone/update repositories
echo -e "${BLUE}Setting up repositories...${NC}"
./setup-repos.sh

# Setup modules
echo -e "${BLUE}Setting up module symlinks...${NC}"
./setup-modules.sh

# Install dependencies
echo -e "${BLUE}Installing Python dependencies...${NC}"
read -p "Do you want to install Python dependencies now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./install-dependencies.sh
else
    echo -e "${YELLOW}Skipping dependency installation. You can run ./install-dependencies.sh later${NC}"
fi

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    Setup Complete!                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${GREEN}✓ All setup steps completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. ${YELLOW}Activate virtual environment (if created):${NC}"
echo -e "     source venv/bin/activate"
echo ""
echo -e "  2. ${YELLOW}Start Odoo:${NC}"
echo -e "     ./run-odoo.sh"
echo ""
echo -e "  3. ${YELLOW}Access Odoo:${NC}"
echo -e "     Web: http://localhost:8069"
echo -e "     PgAdmin: http://localhost:5050 (admin@odoo.local / admin)"
echo ""
echo -e "  4. ${YELLOW}Create your first database:${NC}"
echo -e "     Open http://localhost:8069 and create a new database"
echo ""
echo -e "${BLUE}Additional commands:${NC}"
echo -e "  ${YELLOW}Update repositories:${NC}     ./setup-repos.sh"
echo -e "  ${YELLOW}Refresh module links:${NC}    ./setup-modules.sh"
echo -e "  ${YELLOW}Stop database:${NC}            docker-compose down"
echo -e "  ${YELLOW}View database logs:${NC}       docker-compose logs -f postgres"
echo ""
