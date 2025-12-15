#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${CYAN}Odoo 18 Development Environment Manager${NC}"
    echo ""
    echo "Usage: ./manage.sh [command]"
    echo ""
    echo "Commands:"
    echo -e "  ${GREEN}setup${NC}              - Run initial setup (clone repos, setup modules, start DB)"
    echo -e "  ${GREEN}start${NC}              - Start Odoo server"
    echo -e "  ${GREEN}db-start${NC}           - Start PostgreSQL database"
    echo -e "  ${GREEN}db-stop${NC}            - Stop PostgreSQL database"
    echo -e "  ${GREEN}db-restart${NC}         - Restart PostgreSQL database"
    echo -e "  ${GREEN}db-logs${NC}            - View PostgreSQL logs"
    echo -e "  ${GREEN}update-repos${NC}       - Update all repositories"
    echo -e "  ${GREEN}update-modules${NC}     - Refresh module symlinks"
    echo -e "  ${GREEN}install-deps${NC}       - Install Python dependencies"
    echo -e "  ${GREEN}list-modules${NC}       - List all available modules"
    echo -e "  ${GREEN}clean${NC}              - Remove all data (repositories, modules, data)"
    echo -e "  ${GREEN}status${NC}             - Show environment status"
    echo -e "  ${GREEN}help${NC}               - Show this help message"
    echo ""
}

check_env() {
    if [ ! -f .env ]; then
        echo -e "${RED}Error: .env file not found!${NC}"
        echo -e "${YELLOW}Run: ./manage.sh setup${NC}"
        exit 1
    fi
}

status() {
    echo -e "${CYAN}Environment Status${NC}"
    echo ""

    # Check .env
    if [ -f .env ]; then
        echo -e "${GREEN}✓${NC} .env file exists"
    else
        echo -e "${RED}✗${NC} .env file missing"
    fi

    # Check repositories
    if [ -d "repositories/odoo" ]; then
        echo -e "${GREEN}✓${NC} Odoo repository cloned"
    else
        echo -e "${RED}✗${NC} Odoo repository not found"
    fi

    if [ -d "repositories/enterprise" ]; then
        echo -e "${GREEN}✓${NC} Enterprise repository cloned"
    else
        echo -e "${YELLOW}!${NC} Enterprise repository not found"
    fi

    # Check modules
    if [ -d "odoo_modules" ]; then
        MODULE_COUNT=$(find odoo_modules -type l 2>/dev/null | wc -l | xargs)
        echo -e "${GREEN}✓${NC} Module symlinks: $MODULE_COUNT modules"
    else
        echo -e "${RED}✗${NC} odoo_modules directory not found"
    fi

    # Check virtual environment
    if [ -d "venv" ]; then
        echo -e "${GREEN}✓${NC} Virtual environment exists"
    else
        echo -e "${YELLOW}!${NC} Virtual environment not found"
    fi

    # Check database
    if docker-compose ps postgres 2>/dev/null | grep -q "Up"; then
        echo -e "${GREEN}✓${NC} PostgreSQL is running"
    else
        echo -e "${YELLOW}!${NC} PostgreSQL is not running"
    fi

    echo ""
}

list_modules() {
    if [ ! -d "odoo_modules" ]; then
        echo -e "${RED}No modules found. Run ./manage.sh update-modules first${NC}"
        exit 1
    fi

    echo -e "${CYAN}Available Modules:${NC}"
    echo ""

    MODULE_COUNT=$(find odoo_modules -type l | wc -l | xargs)
    echo -e "${BLUE}Total: $MODULE_COUNT modules${NC}"
    echo ""

    ls -1 odoo_modules | column
}

clean() {
    echo -e "${RED}WARNING: This will remove all repositories, modules, and data!${NC}"
    read -p "Are you sure? (type 'yes' to confirm): " -r

    if [ "$REPLY" != "yes" ]; then
        echo -e "${YELLOW}Cancelled${NC}"
        exit 0
    fi

    echo -e "${BLUE}Stopping database...${NC}"
    docker-compose down -v

    echo -e "${BLUE}Removing directories...${NC}"
    rm -rf repositories/ odoo_modules/ odoo_data/

    echo -e "${GREEN}✓ Clean complete${NC}"
    echo -e "${YELLOW}Run ./manage.sh setup to start fresh${NC}"
}

case "$1" in
    setup)
        ./setup.sh
        ;;
    start)
        check_env
        ./run-odoo.sh
        ;;
    db-start)
        docker-compose up -d postgres
        echo -e "${GREEN}✓ PostgreSQL started${NC}"
        ;;
    db-stop)
        docker-compose down
        echo -e "${GREEN}✓ PostgreSQL stopped${NC}"
        ;;
    db-restart)
        docker-compose restart postgres
        echo -e "${GREEN}✓ PostgreSQL restarted${NC}"
        ;;
    db-logs)
        docker-compose logs -f postgres
        ;;
    update-repos)
        check_env
        ./setup-repos.sh
        ;;
    update-modules)
        ./setup-modules.sh
        ;;
    install-deps)
        ./install-dependencies.sh
        ;;
    list-modules)
        list_modules
        ;;
    clean)
        clean
        ;;
    status)
        status
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
