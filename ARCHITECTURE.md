# Architecture Overview

## Directory Structure

```
odoo/18.0/
│
├── Configuration Files
│   ├── .env                      # Environment variables (GitHub token, ports, etc.)
│   ├── .env.example              # Template for .env
│   ├── repos.json                # Repository configuration
│   ├── odoo.conf                 # Odoo server configuration
│   ├── docker-compose.yml        # PostgreSQL & pgAdmin setup
│   └── .gitignore                # Git ignore rules
│
├── Scripts
│   ├── manage.sh                 # Main management script (recommended)
│   ├── setup.sh                  # Initial setup orchestrator
│   ├── setup-repos.sh            # Clone/update repositories
│   ├── setup-modules.sh          # Create module symlinks
│   ├── install-dependencies.sh   # Install Python packages
│   └── run-odoo.sh               # Start Odoo server
│
├── Documentation
│   ├── README.md                 # Comprehensive documentation
│   ├── QUICKSTART.md             # Quick start guide
│   └── ARCHITECTURE.md           # This file
│
├── Runtime Directories (created during setup)
│   ├── repositories/             # Git repositories
│   │   ├── odoo/                # Odoo core (branch 18.0)
│   │   └── enterprise/          # Enterprise modules (branch 18.0)
│   │
│   ├── odoo_modules/            # Symbolic links to all modules
│   │   ├── sale -> repositories/enterprise/sale
│   │   ├── account -> repositories/odoo/addons/account
│   │   └── ... (all modules)
│   │
│   ├── odoo_data/               # Odoo runtime data (filestore, sessions)
│   └── venv/                    # Python virtual environment (optional)
│
└── Docker Volumes
    ├── odoo_postgres_data       # PostgreSQL database files
    └── odoo_pgadmin_data        # pgAdmin configuration
```

## Component Interaction

```
┌─────────────────────────────────────────────────────────────┐
│                     Developer Workflow                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │  manage.sh    │  ◄── Main entry point
                    └───────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  setup.sh     │   │ run-odoo.sh   │   │  Database     │
│  (one-time)   │   │  (daily)      │   │  Commands     │
└───────────────┘   └───────────────┘   └───────────────┘
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│setup-repos.sh │   │ Odoo Server   │   │Docker Compose │
│setup-modules  │   │ (Python)      │   │(PostgreSQL)   │
│install-deps   │   └───────────────┘   └───────────────┘
└───────────────┘           │
                            ▼
                    ┌───────────────┐
                    │ odoo_modules/ │  ◄── Symlinks
                    │  (all addons) │
                    └───────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ repositories/ │   │ repositories/ │   │   Custom      │
│  odoo/        │   │  enterprise/  │   │ Repositories  │
└───────────────┘   └───────────────┘   └───────────────┘
```

## Data Flow

### 1. Initial Setup

```
User runs ./manage.sh setup
    │
    ├─► Check .env file exists
    │
    ├─► Start PostgreSQL (docker-compose)
    │
    ├─► Clone repositories (setup-repos.sh)
    │   ├─► Read repos.json
    │   ├─► Clone odoo (branch 18.0)
    │   └─► Clone enterprise (with GitHub token)
    │
    ├─► Create module symlinks (setup-modules.sh)
    │   ├─► Scan all repositories
    │   ├─► Find modules (__manifest__.py)
    │   └─► Create symlinks in odoo_modules/
    │
    └─► Install Python dependencies (optional)
        └─► pip install from odoo/requirements.txt
```

### 2. Running Odoo

```
User runs ./manage.sh start
    │
    ├─► Load .env configuration
    │
    ├─► Build addons path
    │   ├─► repositories/odoo/addons
    │   ├─► repositories/odoo/odoo/addons
    │   ├─► repositories/enterprise
    │   └─► odoo_modules (all symlinks)
    │
    ├─► Update odoo.conf
    │
    └─► Start Odoo
        ├─► Connect to PostgreSQL
        ├─► Load modules from addons_path
        ├─► Start web server (port 8069)
        └─► Enable auto-reload (dev mode)
```

### 3. Adding New Repository

```
User edits repos.json
    │
    ├─► Add new repository entry
    │
User runs ./manage.sh update-repos
    │
    ├─► Clone new repository
    │
User runs ./manage.sh update-modules
    │
    └─► Create symlinks for new modules
```

## Module Resolution

When Odoo loads modules, it searches the `addons_path` in order:

```
addons_path = repositories/odoo/addons,
              repositories/odoo/odoo/addons,
              repositories/enterprise,
              odoo_modules

Module search order:
1. repositories/odoo/addons/          (Core addons)
2. repositories/odoo/odoo/addons/     (Base addons)
3. repositories/enterprise/            (Enterprise modules)
4. odoo_modules/                       (All modules via symlinks)
```

**Note**: If a module exists in multiple locations, the first one found is used.

## Authentication Flow

### GitHub Token Usage

```
User creates GitHub token
    │
    ├─► Token stored in .env
    │
When cloning private repos (enterprise):
    │
    ├─► setup-repos.sh reads GITHUB_TOKEN
    │
    ├─► Converts SSH URL to HTTPS
    │   git@github.com:odoo/enterprise.git
    │   ↓
    │   https://x-access-token:TOKEN@github.com/odoo/enterprise.git
    │
    └─► Git clones with authentication
```

## Database Architecture

```
Docker Container: odoo18_postgres
    │
    ├─► PostgreSQL 15
    ├─► Port: 5432 (mapped to host)
    ├─► User: odoo
    ├─► Password: odoo
    └─► Data: Docker volume (persistent)

Odoo creates databases dynamically:
    │
    ├─► Database 1 (e.g., 'production')
    ├─► Database 2 (e.g., 'development')
    └─► Database 3 (e.g., 'testing')

Each database is independent with its own:
    ├─► Schema
    ├─► Modules
    └─► Data
```

## Python Environment

```
System Python 3.10+
    │
    ├─► Optional: Virtual Environment (venv/)
    │   ├─► Isolated dependencies
    │   └─► Recommended for development
    │
    └─► Required Packages:
        ├─► Odoo dependencies (requirements.txt)
        ├─► PostgreSQL driver (psycopg2)
        ├─► Web framework (Werkzeug)
        ├─► XML/HTML (lxml)
        ├─► Images (Pillow)
        ├─► PDF (reportlab)
        └─► Development tools (debugpy, ipdb, etc.)
```

## Script Responsibilities

### manage.sh (Master Controller)
- Single entry point for all operations
- Orchestrates other scripts
- Provides status information
- User-friendly interface

### setup.sh (Initial Setup)
- First-time environment setup
- Validates prerequisites
- Coordinates setup-repos.sh and setup-modules.sh
- Interactive prompts

### setup-repos.sh (Repository Manager)
- Reads repos.json configuration
- Clones new repositories
- Updates existing repositories
- Handles GitHub authentication

### setup-modules.sh (Module Linker)
- Scans all repositories for modules
- Creates symbolic links in odoo_modules/
- Supports core and addon repository types
- Validates module structure

### install-dependencies.sh (Dependency Installer)
- Checks Python version
- Offers virtual environment creation
- Installs Odoo requirements
- Installs development tools

### run-odoo.sh (Odoo Launcher)
- Builds addons_path dynamically
- Updates odoo.conf
- Starts Odoo server
- Passes arguments to odoo-bin

## Configuration Files

### .env
- Environment variables
- Secrets (GitHub token)
- Port configurations
- Database credentials

### repos.json
- Repository list
- Branch specifications
- Repository types (core/addons)
- Authentication requirements

### odoo.conf
- Odoo server settings
- Database connection
- Development mode
- Logging configuration
- Addons path (updated dynamically)

### docker-compose.yml
- PostgreSQL service
- pgAdmin service
- Volume management
- Network configuration

## Security Considerations

1. **GitHub Token**: Stored in `.env`, excluded from git via `.gitignore`
2. **Database Password**: Configurable via `.env`, defaults provided for development
3. **Admin Password**: Set in `odoo.conf`, should be changed for production
4. **File Permissions**: Scripts are executable, data directories are private

## Extensibility

### Adding New Repository Types

Edit `setup-repos.sh` and `setup-modules.sh` to support new repository types:

```json
{
  "type": "custom-type",
  ...
}
```

### Custom Scripts

Add new scripts following the pattern:
- Use color coding for output
- Load `.env` for configuration
- Provide clear error messages
- Include usage documentation

### Module Organization

The symbolic link approach allows:
- Easy module discovery
- Version control of custom modules
- Separation of concerns
- Clean repository structure

## Performance Considerations

1. **Symbolic Links**: Fast module resolution, no file duplication
2. **Virtual Environment**: Isolated dependencies, no conflicts
3. **Docker Volumes**: Persistent data, fast I/O
4. **Development Mode**: Auto-reload for rapid development

## Backup Strategy

What to backup:
- `odoo_data/` - Odoo filestore and sessions
- PostgreSQL database (docker volume or dump)
- `.env` - Environment configuration
- `repos.json` - Repository configuration

What NOT to backup (regenerable):
- `repositories/` - Can be cloned again
- `odoo_modules/` - Symlinks, regenerated by setup-modules.sh
- `venv/` - Virtual environment, regenerated by install-dependencies.sh
