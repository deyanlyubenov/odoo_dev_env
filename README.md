# Odoo 18 Enterprise Development Environment

Automated development environment setup for Odoo 18 Enterprise with support for multiple addon repositories.

## Features

- **Automated repository management**: Clone and update Odoo core and enterprise modules
- **GitHub token authentication**: Secure access to private enterprise repository
- **Modular architecture**: Easy addition of custom addon repositories
- **Symbolic link management**: All modules accessible from a single `odoo_modules` directory
- **Automated dependency installation**: Python packages installed automatically
- **Docker PostgreSQL**: Containerized database with pgAdmin interface
- **Development-ready configuration**: Auto-reload, debugging support, and more

## Prerequisites

- **macOS/Linux** (Windows users can adapt the bash scripts)
- **Python 3.10+** installed
- **Docker Desktop** installed and running
- **Git** installed
- **GitHub Personal Access Token** with `repo` scope (for enterprise modules)

## Quick Start

### 1. Initial Setup

```bash
# Make scripts executable
chmod +x *.sh

# Run the main setup script
./setup.sh
```

The setup script will:
1. Create `.env` file from template (you'll need to add your GitHub token)
2. Start PostgreSQL database
3. Clone Odoo core and enterprise repositories
4. Create symbolic links for all modules
5. Optionally install Python dependencies

### 2. Configure GitHub Token

Edit `.env` file and add your GitHub token:

```bash
GITHUB_TOKEN=ghp_your_token_here
```

Generate a token at: https://github.com/settings/tokens
Required scope: `repo` (Full control of private repositories)

### 3. Install Python Dependencies

If you skipped this during setup:

```bash
# Optional: Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
./install-dependencies.sh
```

### 4. Start Odoo

```bash
./run-odoo.sh
```

Access Odoo at: http://localhost:8069

## Project Structure

```
.
├── .env                    # Environment configuration (created from .env.example)
├── .env.example            # Environment template
├── repos.json              # Repository configuration
├── odoo.conf              # Odoo configuration file
├── docker-compose.yml     # PostgreSQL and pgAdmin setup
├── setup.sh               # Main setup script
├── setup-repos.sh         # Clone/update repositories
├── setup-modules.sh       # Create module symlinks
├── install-dependencies.sh # Install Python packages
├── run-odoo.sh            # Start Odoo server
├── repositories/          # Cloned repositories
│   ├── odoo/             # Odoo core (branch 18.0)
│   └── enterprise/       # Enterprise modules (branch 18.0)
├── odoo_modules/         # Symbolic links to all modules
├── odoo_data/            # Odoo data directory
└── venv/                 # Python virtual environment (optional)
```

## Adding Custom Repositories

Edit `repos.json` to add custom addon repositories:

```json
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
      "name": "custom-addons",
      "url": "git@github.com:yourcompany/custom-addons.git",
      "branch": "18.0",
      "type": "addons",
      "enabled": true,
      "requires_auth": false
    }
  ]
}
```

Then run:

```bash
./setup-repos.sh      # Clone/update repositories
./setup-modules.sh    # Refresh module symlinks
```

### Repository Types

- **core**: Odoo core repository (links `addons/` and `odoo/addons/`)
- **addons**: Addon repository (links all modules in root directory)

## Common Commands

### Development Workflow

```bash
# Start Odoo in development mode
./run-odoo.sh

# Start Odoo with specific database
./run-odoo.sh -d mydb

# Update module list
./run-odoo.sh -d mydb -u all

# Install specific module
./run-odoo.sh -d mydb -i sale

# Start without demo data
./run-odoo.sh --without-demo=all
```

### Repository Management

```bash
# Update all repositories
./setup-repos.sh

# Refresh module symbolic links
./setup-modules.sh

# Update dependencies
./install-dependencies.sh
```

### Database Management

```bash
# Start database
docker-compose up -d postgres

# Stop database
docker-compose down

# View database logs
docker-compose logs -f postgres

# Access pgAdmin
# Open http://localhost:5050
# Login: admin@odoo.local / admin
```

### Database Operations

```bash
# Create database
./run-odoo.sh -d mydb -i base

# Drop database (WARNING: destructive)
./run-odoo.sh -d mydb --stop-after-init --db-filter=^mydb$ --database=postgres -c "DROP DATABASE IF EXISTS mydb"

# List databases
./run-odoo.sh --list-db
```

## Development Tips

### Virtual Environment

Always use a virtual environment for Python dependencies:

```bash
python3 -m venv venv
source venv/bin/activate
./install-dependencies.sh
```

### Auto-reload

The configuration includes `dev_mode = reload,qweb,werkzeug,xml` for automatic reloading during development.

### Debugging

The setup includes `debugpy` for Python debugging. You can attach VS Code or PyCharm to the running process.

### Module Development

1. Create your module in a custom repository
2. Add repository to `repos.json`
3. Run `./setup-repos.sh` and `./setup-modules.sh`
4. Your module will be available in `odoo_modules/`

## Configuration

### Environment Variables (.env)

```bash
# GitHub Authentication
GITHUB_TOKEN=your_token

# Odoo Settings
ODOO_VERSION=18.0
ODOO_PORT=8069
ODOO_LONGPOLLING_PORT=8072

# Database Settings
POSTGRES_USER=odoo
POSTGRES_PASSWORD=odoo
POSTGRES_DB=postgres
POSTGRES_PORT=5432

# Admin Password
ODOO_ADMIN_PASSWORD=admin
```

### Odoo Configuration (odoo.conf)

The `odoo.conf` file is pre-configured for development with:
- Auto-reload enabled
- Development mode active
- Logging configured
- Database connection settings
- Data directory setup

Modify `odoo.conf` directly for advanced configuration.

## Troubleshooting

### GitHub Authentication Failed

- Verify your token in `.env` has the `repo` scope
- Test token: `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user`
- Regenerate token if needed at https://github.com/settings/tokens

### PostgreSQL Connection Error

```bash
# Check if PostgreSQL is running
docker-compose ps

# Restart PostgreSQL
docker-compose restart postgres

# Check logs
docker-compose logs postgres
```

### Module Not Found

```bash
# Refresh module symlinks
./setup-modules.sh

# Verify module is linked
ls -la odoo_modules/ | grep your_module

# Update module list in Odoo
./run-odoo.sh -d mydb -u all
```

### Python Dependencies Issues

```bash
# Reinstall dependencies
pip3 install --upgrade --force-reinstall -r repositories/odoo/requirements.txt

# Or run the install script again
./install-dependencies.sh
```

### Permission Denied

```bash
# Make scripts executable
chmod +x *.sh
```

## Maintenance

### Update Repositories

```bash
# Update all repositories to latest version
./setup-repos.sh
```

### Clean Installation

```bash
# Stop and remove database
docker-compose down -v

# Remove repositories and modules
rm -rf repositories/ odoo_modules/ odoo_data/

# Run setup again
./setup.sh
```

## Resources

- [Odoo Documentation](https://www.odoo.com/documentation/18.0/)
- [Odoo Developer Documentation](https://www.odoo.com/documentation/18.0/developer.html)
- [GitHub - Odoo](https://github.com/odoo/odoo)
- [Odoo Community](https://www.odoo.com/forum)

## License

This development environment setup is provided as-is. Odoo itself is licensed under LGPL-3.0.

## Support

For issues with this setup:
1. Check the Troubleshooting section
2. Review script output for error messages
3. Verify all prerequisites are installed

For Odoo-specific questions, refer to the official Odoo documentation.
