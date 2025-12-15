# Usage Examples

This document provides practical examples for common Odoo development scenarios.

## Table of Contents
- [First Time Setup](#first-time-setup)
- [Daily Development Workflow](#daily-development-workflow)
- [Module Development](#module-development)
- [Database Management](#database-management)
- [Multi-Repository Setup](#multi-repository-setup)
- [Debugging](#debugging)
- [Testing](#testing)

---

## First Time Setup

### Complete Initial Setup

```bash
# 1. Configure environment
cp .env.example .env
nano .env  # Add your GitHub token

# 2. Run setup
./manage.sh setup

# 3. Activate virtual environment (if created)
source venv/bin/activate

# 4. Start Odoo
./manage.sh start
```

### Manual Step-by-Step Setup

```bash
# Configure environment
cp .env.example .env
nano .env

# Start database only
./manage.sh db-start

# Clone repositories
./setup-repos.sh

# Create module symlinks
./setup-modules.sh

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
./install-dependencies.sh

# Start Odoo
./run-odoo.sh
```

---

## Daily Development Workflow

### Starting Your Day

```bash
# Check environment status
./manage.sh status

# Start database (if not running)
./manage.sh db-start

# Activate virtual environment
source venv/bin/activate

# Start Odoo
./manage.sh start
```

### Ending Your Day

```bash
# Stop Odoo (Ctrl+C in the terminal where it's running)

# Stop database
./manage.sh db-stop
```

### Quick Restart

```bash
# In one terminal: restart database
./manage.sh db-restart

# In another terminal: restart Odoo
# (Ctrl+C then ./manage.sh start)
```

---

## Module Development

### Scenario 1: Develop Custom Module in Existing Repository

```bash
# 1. Navigate to enterprise repository
cd repositories/enterprise

# 2. Create new module
mkdir my_custom_module
cd my_custom_module

# 3. Create __manifest__.py
cat > __manifest__.py << 'EOF'
{
    'name': 'My Custom Module',
    'version': '18.0.1.0.0',
    'category': 'Custom',
    'summary': 'Custom module description',
    'depends': ['base', 'sale'],
    'data': [
        'security/ir.model.access.csv',
        'views/views.xml',
    ],
    'installable': True,
    'application': False,
}
EOF

# 4. Create module structure
mkdir -p models views security
touch models/__init__.py
touch views/views.xml
touch security/ir.model.access.csv

# 5. Go back to project root
cd ../../..

# 6. Refresh module links
./manage.sh update-modules

# 7. Restart Odoo and install module
./run-odoo.sh -d mydb -u my_custom_module
```

### Scenario 2: Create Separate Custom Repository

```bash
# 1. Create repository outside Odoo project
cd ~/Projects
mkdir my-custom-odoo-addons
cd my-custom-odoo-addons
git init

# 2. Create module structure
mkdir my_module
cd my_module
# ... create __manifest__.py and module files ...

# 3. Commit and push to GitHub
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:yourcompany/my-custom-addons.git
git push -u origin main

# 4. Go back to Odoo project
cd ~/Documents/Projects/Mayla/odoo/18.0

# 5. Add repository to repos.json
nano repos.json
# Add:
# {
#   "name": "my-custom-addons",
#   "url": "git@github.com:yourcompany/my-custom-addons.git",
#   "branch": "main",
#   "type": "addons",
#   "enabled": true,
#   "requires_auth": false
# }

# 6. Clone repository and setup modules
./manage.sh update-repos
./manage.sh update-modules

# 7. Verify module is available
./manage.sh list-modules | grep my_module

# 8. Install module
./run-odoo.sh -d mydb -i my_module
```

---

## Database Management

### Create New Database

```bash
# Method 1: Via Web Interface
# Open http://localhost:8069
# Click "Create Database"
# Fill in details

# Method 2: Command Line
./run-odoo.sh -d production -i base --stop-after-init

# Method 3: With specific modules
./run-odoo.sh -d production -i base,sale,account --stop-after-init
```

### Clone Database

```bash
# Using psql
docker exec -it odoo18_postgres psql -U odoo -c "CREATE DATABASE production_copy TEMPLATE production;"

# Or using pgAdmin at http://localhost:5050
```

### Backup Database

```bash
# Backup to file
docker exec -it odoo18_postgres pg_dump -U odoo -d production > backup_production_$(date +%Y%m%d).sql

# Restore from backup
docker exec -i odoo18_postgres psql -U odoo -d production_restored < backup_production_20231215.sql
```

### Drop Database

```bash
# Using Odoo
./run-odoo.sh -d production --stop-after-init

# Using psql
docker exec -it odoo18_postgres psql -U odoo -c "DROP DATABASE production;"
```

### Reset Database (Keep Structure)

```bash
# Drop and recreate
docker exec -it odoo18_postgres psql -U odoo << EOF
DROP DATABASE production;
CREATE DATABASE production;
EOF

# Reinstall base modules
./run-odoo.sh -d production -i base --stop-after-init
```

---

## Multi-Repository Setup

### Scenario: Company with Multiple Addon Repositories

```json
// repos.json
{
  "repositories": [
    {
      "name": "odoo",
      "url": "git@github.com:odoo/odoo.git",
      "branch": "18.0",
      "type": "core",
      "enabled": true
    },
    {
      "name": "enterprise",
      "url": "git@github.com:odoo/enterprise.git",
      "branch": "18.0",
      "type": "addons",
      "enabled": true,
      "requires_auth": true
    },
    {
      "name": "company-core-addons",
      "url": "git@github.com:mycompany/core-addons.git",
      "branch": "18.0",
      "type": "addons",
      "enabled": true,
      "requires_auth": false
    },
    {
      "name": "company-industry-addons",
      "url": "git@github.com:mycompany/industry-addons.git",
      "branch": "18.0",
      "type": "addons",
      "enabled": true,
      "requires_auth": false
    },
    {
      "name": "third-party-oca",
      "url": "git@github.com:OCA/some-oca-repo.git",
      "branch": "18.0",
      "type": "addons",
      "enabled": true,
      "requires_auth": false
    }
  ]
}
```

```bash
# Setup all repositories
./manage.sh update-repos
./manage.sh update-modules

# Verify all modules
./manage.sh list-modules

# Start Odoo with all addons
./manage.sh start
```

### Temporarily Disable Repository

```json
// In repos.json, set enabled to false
{
  "name": "third-party-oca",
  "url": "git@github.com:OCA/some-oca-repo.git",
  "branch": "18.0",
  "type": "addons",
  "enabled": false,  // <-- Changed to false
  "requires_auth": false
}
```

```bash
# Refresh modules (disabled repos will be skipped)
./manage.sh update-modules
```

---

## Debugging

### Debug with Visual Studio Code

```bash
# 1. Install debugpy (already included in install-dependencies.sh)
pip install debugpy

# 2. Start Odoo with debugging enabled
./run-odoo.sh --dev=xml,qweb,reload
```

Create `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Odoo: Attach",
            "type": "python",
            "request": "attach",
            "port": 5678,
            "host": "localhost",
            "pathMappings": [
                {
                    "localRoot": "${workspaceFolder}/repositories/odoo",
                    "remoteRoot": "${workspaceFolder}/repositories/odoo"
                }
            ]
        }
    ]
}
```

### Debug with iPython/ipdb

```bash
# In your Python code, add:
import ipdb; ipdb.set_trace()

# Or use iPython
import IPython; IPython.embed()
```

### Enable Debug Logging

```bash
# Edit odoo.conf
nano odoo.conf

# Change log_level to debug
log_level = debug
log_handler = :DEBUG

# Or start with specific log handler
./run-odoo.sh --log-handler=odoo.addons.my_module:DEBUG
```

---

## Testing

### Run All Tests

```bash
# Run tests for all installed modules
./run-odoo.sh -d test_db --test-enable --stop-after-init

# Run tests with specific log level
./run-odoo.sh -d test_db --test-enable --log-level=test --stop-after-init
```

### Run Tests for Specific Module

```bash
# Install module and run its tests
./run-odoo.sh -d test_db -i my_module --test-enable --stop-after-init

# Update module and run tests
./run-odoo.sh -d test_db -u my_module --test-enable --stop-after-init
```

### Run Tests with Tags

```bash
# Run only tests with specific tag
./run-odoo.sh -d test_db --test-enable --test-tags=post_install --stop-after-init

# Run tests excluding certain tags
./run-odoo.sh -d test_db --test-enable --test-tags=-at_install --stop-after-init
```

### Create Test Database

```bash
# Create dedicated test database
./run-odoo.sh -d test_database -i base --without-demo=all --stop-after-init

# Run tests
./run-odoo.sh -d test_database -u my_module --test-enable --stop-after-init

# Drop test database when done
docker exec -it odoo18_postgres psql -U odoo -c "DROP DATABASE test_database;"
```

---

## Advanced Scenarios

### Scenario: Multiple Odoo Versions

```bash
# Create separate directories for each version
mkdir -p ~/odoo/16.0
mkdir -p ~/odoo/17.0
mkdir -p ~/odoo/18.0

# Copy scripts to each directory
cp -r ~/odoo/18.0/* ~/odoo/16.0/
cp -r ~/odoo/18.0/* ~/odoo/17.0/

# Modify repos.json in each directory to use correct branch
cd ~/odoo/16.0
nano repos.json  # Change branch to 16.0

cd ~/odoo/17.0
nano repos.json  # Change branch to 17.0

# Modify .env to use different ports
# 16.0: ports 8016, 5416
# 17.0: ports 8017, 5417
# 18.0: ports 8069, 5432
```

### Scenario: Hot-swap Modules During Development

```bash
# Terminal 1: Watch for changes
cd repositories/enterprise/my_module
watch -n 2 'git status'

# Terminal 2: Run Odoo with auto-reload
cd ~/Documents/Projects/Mayla/odoo/18.0
./run-odoo.sh -d dev --dev=all

# Make changes to module files
# Odoo will automatically reload
```

### Scenario: Performance Testing

```bash
# Start Odoo with workers for production-like environment
./run-odoo.sh -d perf_test --workers=4 --max-cron-threads=2

# Or edit odoo.conf:
# workers = 4
# max_cron_threads = 2
```

---

## Troubleshooting Examples

### Problem: Module Not Found

```bash
# Check if module exists in repositories
find repositories -name "my_module" -type d

# Refresh module links
./manage.sh update-modules

# Verify symlink
ls -la odoo_modules/ | grep my_module

# Update module list in Odoo
./run-odoo.sh -d mydb -u all
```

### Problem: Import Error

```bash
# Check if dependency is installed
pip list | grep package_name

# Reinstall dependencies
./manage.sh install-deps

# Or install specific package
pip install package_name
```

### Problem: Database Connection Error

```bash
# Check if PostgreSQL is running
./manage.sh status

# Check database logs
./manage.sh db-logs

# Restart database
./manage.sh db-restart

# Test connection
docker exec -it odoo18_postgres psql -U odoo -c "SELECT version();"
```

### Problem: Port Already in Use

```bash
# Find what's using port 8069
lsof -i :8069

# Kill process
kill -9 <PID>

# Or change port in .env
nano .env
# ODOO_PORT=8070
```

---

## Maintenance Examples

### Weekly Updates

```bash
# Update all repositories
./manage.sh update-repos

# Refresh module links
./manage.sh update-modules

# Update Python dependencies
source venv/bin/activate
./manage.sh install-deps

# Restart Odoo
./manage.sh db-restart
./manage.sh start
```

### Monthly Cleanup

```bash
# Check disk usage
du -sh repositories/ odoo_data/

# Clean Python cache
find . -type d -name "__pycache__" -exec rm -rf {} +

# Clean old log files
find odoo_data -name "*.log" -mtime +30 -delete

# Vacuum database
docker exec -it odoo18_postgres psql -U odoo -c "VACUUM ANALYZE;"
```

### Backup Before Major Changes

```bash
# Create backup directory
mkdir -p ~/backups/odoo_$(date +%Y%m%d)

# Backup databases
docker exec odoo18_postgres pg_dumpall -U odoo > ~/backups/odoo_$(date +%Y%m%d)/all_databases.sql

# Backup filestore
cp -r odoo_data ~/backups/odoo_$(date +%Y%m%d)/

# Backup configuration
cp .env repos.json odoo.conf ~/backups/odoo_$(date +%Y%m%d)/
```
