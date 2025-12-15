#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up Odoo modules with symbolic links...${NC}"

# Create odoo_modules directory if it doesn't exist
mkdir -p odoo_modules

# Clear existing symlinks in odoo_modules
echo -e "${YELLOW}Cleaning up existing symbolic links...${NC}"
find odoo_modules -type l -delete

# Function to create symlinks for modules in a directory
create_module_symlinks() {
    local source_dir=$1
    local repo_name=$2

    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}Warning: Directory $source_dir not found, skipping...${NC}"
        return
    fi

    echo -e "${BLUE}Processing modules from $repo_name...${NC}"

    # Find all modules (directories containing __manifest__.py or __openerp__.py)
    for module_path in "$source_dir"/*; do
        if [ -d "$module_path" ]; then
            module_name=$(basename "$module_path")

            # Check if it's a valid Odoo module
            if [ -f "$module_path/__manifest__.py" ] || [ -f "$module_path/__openerp__.py" ]; then
                # Create absolute path
                abs_module_path=$(cd "$module_path" && pwd)

                # Create symlink in odoo_modules
                if [ -L "odoo_modules/$module_name" ]; then
                    echo -e "${YELLOW}  - Symlink for $module_name already exists, skipping${NC}"
                else
                    ln -s "$abs_module_path" "odoo_modules/$module_name"
                    echo -e "${GREEN}  ✓ Created symlink for $module_name${NC}"
                fi
            fi
        fi
    done
}

# Read repositories from repos.json
REPOS=$(cat repos.json | python3 -c "
import sys, json
data = json.load(sys.stdin)
for repo in data['repositories']:
    if repo.get('enabled', True):
        print(f\"{repo['name']}|{repo['type']}\")
")

# Process each repository
while IFS='|' read -r name type; do
    REPO_PATH="repositories/$name"

    if [ "$type" = "core" ]; then
        # For core Odoo, link addons and odoo/addons directories
        if [ -d "$REPO_PATH/addons" ]; then
            create_module_symlinks "$REPO_PATH/addons" "$name/addons"
        fi
        if [ -d "$REPO_PATH/odoo/addons" ]; then
            create_module_symlinks "$REPO_PATH/odoo/addons" "$name/odoo/addons"
        fi
    elif [ "$type" = "addons" ]; then
        # For addon repositories, link the root directory
        create_module_symlinks "$REPO_PATH" "$name"
    fi
done <<< "$REPOS"

# Count total modules
TOTAL_MODULES=$(find odoo_modules -type l | wc -l | xargs)
echo -e "${GREEN}✓ Setup complete! Total modules linked: $TOTAL_MODULES${NC}"

# List all modules
echo -e "${BLUE}Available modules:${NC}"
ls -1 odoo_modules | head -20
if [ $TOTAL_MODULES -gt 20 ]; then
    echo -e "${YELLOW}... and $(($TOTAL_MODULES - 20)) more${NC}"
fi
