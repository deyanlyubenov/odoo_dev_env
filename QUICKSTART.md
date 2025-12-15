# Quick Start Guide

## Initial Setup (First Time Only)

### 1. Configure GitHub Token

```bash
# Copy environment template
cp .env.example .env

# Edit .env and add your GitHub token
# Get token from: https://github.com/settings/tokens
# Required scope: repo
nano .env
```

### 2. Run Setup

```bash
./manage.sh setup
```

This will:
- Start PostgreSQL database
- Clone Odoo and Enterprise repositories
- Create module symlinks
- Install Python dependencies (optional)

### 3. Start Odoo

```bash
# Option 1: Using manage script
./manage.sh start

# Option 2: Direct script
./run-odoo.sh
```

Open http://localhost:8069 in your browser.

## Daily Workflow

```bash
# Start database (if not running)
./manage.sh db-start

# Start Odoo
./manage.sh start

# When done, stop database
./manage.sh db-stop
```

## Common Operations

### Add New Repository

Edit `repos.json`:

```json
{
  "repositories": [
    ...
    {
      "name": "my-addons",
      "url": "git@github.com:mycompany/my-addons.git",
      "branch": "18.0",
      "type": "addons",
      "enabled": true,
      "requires_auth": false
    }
  ]
}
```

Then update:

```bash
./manage.sh update-repos
./manage.sh update-modules
```

### Install Module

```bash
./run-odoo.sh -d mydb -i module_name
```

### Update Module

```bash
./run-odoo.sh -d mydb -u module_name
```

### Create New Database

```bash
# Open browser and go to http://localhost:8069
# Or use command line:
./run-odoo.sh -d newdb -i base --stop-after-init
```

### View Available Modules

```bash
./manage.sh list-modules
```

### Check Environment Status

```bash
./manage.sh status
```

## Database Management

### pgAdmin Access

- URL: http://localhost:5050
- Email: admin@odoo.local
- Password: admin

### Command Line Access

```bash
# View logs
./manage.sh db-logs

# Restart database
./manage.sh db-restart
```

## Troubleshooting

### PostgreSQL not running

```bash
./manage.sh db-start
```

### Modules not found

```bash
./manage.sh update-modules
```

### Update repositories

```bash
./manage.sh update-repos
```

### Clean installation

```bash
./manage.sh clean
./manage.sh setup
```

## Help

```bash
./manage.sh help
```

For detailed documentation, see [README.md](README.md)
