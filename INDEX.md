# Odoo 18 Development Environment - File Index

## Quick Navigation

### 🚀 Getting Started (Read These First)
1. **[SETUP_SUMMARY.txt](SETUP_SUMMARY.txt)** - Quick overview of what's been created
2. **[QUICKSTART.md](QUICKSTART.md)** - Get up and running in 5 minutes
3. **[README.md](README.md)** - Comprehensive documentation

### 📋 Documentation
- **[README.md](README.md)** - Full documentation with all features and commands
- **[QUICKSTART.md](QUICKSTART.md)** - Fast track to getting started
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture and design
- **[EXAMPLES.md](EXAMPLES.md)** - Practical usage examples and scenarios
- **[SETUP_SUMMARY.txt](SETUP_SUMMARY.txt)** - Initial setup summary
- **[INDEX.md](INDEX.md)** - This file

### ⚙️ Configuration Files
- **[.env.example](.env.example)** - Environment variables template (copy to `.env`)
- **[repos.json](repos.json)** - Repository configuration (add your repos here)
- **[odoo.conf](odoo.conf)** - Odoo server configuration
- **[docker-compose.yml](docker-compose.yml)** - PostgreSQL & pgAdmin setup
- **[.gitignore](.gitignore)** - Git ignore rules

### 🔧 Scripts (Executable)

#### Main Script (Use This!)
- **[manage.sh](manage.sh)** - Master management script for all operations
  ```bash
  ./manage.sh help    # Show all commands
  ./manage.sh setup   # Initial setup
  ./manage.sh start   # Start Odoo
  ./manage.sh status  # Check environment
  ```

#### Individual Scripts
- **[setup.sh](setup.sh)** - Initial setup orchestrator
- **[setup-repos.sh](setup-repos.sh)** - Clone/update repositories
- **[setup-modules.sh](setup-modules.sh)** - Create module symbolic links
- **[install-dependencies.sh](install-dependencies.sh)** - Install Python dependencies
- **[run-odoo.sh](run-odoo.sh)** - Start Odoo server

## File Organization

```
📁 Root Directory
│
├── 📚 Documentation (5 files)
│   ├── README.md              - Main documentation
│   ├── QUICKSTART.md          - Quick start guide
│   ├── ARCHITECTURE.md        - Architecture details
│   ├── EXAMPLES.md            - Usage examples
│   ├── SETUP_SUMMARY.txt      - Setup summary
│   └── INDEX.md               - This file
│
├── ⚙️ Configuration (5 files)
│   ├── .env.example           - Environment template
│   ├── repos.json             - Repository config
│   ├── odoo.conf              - Odoo config
│   ├── docker-compose.yml     - Database setup
│   └── .gitignore             - Git ignore
│
└── 🔧 Scripts (6 executable files)
    ├── manage.sh              - Main script ⭐
    ├── setup.sh               - Setup orchestrator
    ├── setup-repos.sh         - Repository manager
    ├── setup-modules.sh       - Module linker
    ├── install-dependencies.sh - Dependency installer
    └── run-odoo.sh            - Odoo launcher
```

## Common Tasks - Quick Reference

### First Time Setup
```bash
1. Read: SETUP_SUMMARY.txt or QUICKSTART.md
2. Run: cp .env.example .env
3. Edit: .env (add GitHub token)
4. Run: ./manage.sh setup
```

### Daily Usage
```bash
./manage.sh start              # Start everything
./manage.sh status             # Check status
./manage.sh list-modules       # List modules
```

### Adding Repositories
```bash
1. Edit: repos.json
2. Run: ./manage.sh update-repos
3. Run: ./manage.sh update-modules
```

### Need Help?
```bash
./manage.sh help               # Show all commands
```
Or read the appropriate documentation:
- Quick task: **QUICKSTART.md**
- Detailed info: **README.md**
- Examples: **EXAMPLES.md**
- Architecture: **ARCHITECTURE.md**

## Documentation Hierarchy

```
SETUP_SUMMARY.txt (Start here - 2 min read)
    ↓
QUICKSTART.md (Get started - 5 min read)
    ↓
README.md (Learn everything - 15 min read)
    ↓
EXAMPLES.md (Practical scenarios - Reference)
    ↓
ARCHITECTURE.md (Deep dive - Reference)
```

## Files by Purpose

### 🎯 Must Configure
- `.env` (create from `.env.example`) - **Required**: Add GitHub token
- `repos.json` - **Optional**: Add custom repositories

### 📖 Must Read
- `SETUP_SUMMARY.txt` - Overview
- `QUICKSTART.md` - Getting started

### 🔍 Reference When Needed
- `README.md` - Detailed documentation
- `EXAMPLES.md` - Usage scenarios
- `ARCHITECTURE.md` - Technical details

### 🎮 Must Execute
- `manage.sh` - Main control script

### ⚙️ Auto-Generated (During Setup)
These will be created when you run `./manage.sh setup`:
- `repositories/` - Cloned git repositories
- `odoo_modules/` - Symbolic links to modules
- `odoo_data/` - Odoo runtime data
- `venv/` - Python virtual environment (optional)
- `.env` - Your environment config

## File Sizes

- Documentation: ~35 KB (5 files)
- Configuration: ~2.5 KB (5 files)
- Scripts: ~18 KB (6 files)
- **Total: ~56 KB (16 files)**

## Getting Started Checklist

- [ ] Read `SETUP_SUMMARY.txt`
- [ ] Copy `.env.example` to `.env`
- [ ] Add GitHub token to `.env`
- [ ] Run `./manage.sh setup`
- [ ] Run `./manage.sh start`
- [ ] Open http://localhost:8069
- [ ] Create your first database
- [ ] Start developing!

## Need More Information?

| Question | File to Read |
|----------|-------------|
| How do I get started quickly? | QUICKSTART.md |
| How does everything work? | README.md |
| How do I do X? | EXAMPLES.md |
| What's the architecture? | ARCHITECTURE.md |
| What files are there? | INDEX.md (this file) |
| What commands are available? | Run `./manage.sh help` |

## Support

- Run `./manage.sh status` to check environment
- Check logs with `./manage.sh db-logs`
- Read `EXAMPLES.md` for practical scenarios
- Read `README.md` troubleshooting section

## License

This development environment setup is provided as-is for Odoo 18 development.

---

**Last Updated**: December 15, 2025
**Version**: 1.0
**Odoo Version**: 18.0 Enterprise
