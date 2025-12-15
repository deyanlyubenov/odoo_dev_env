# Port Configuration

## PostgreSQL Port

The PostgreSQL container uses **port 5433** on the host machine to avoid conflicts with locally installed PostgreSQL instances.

### Port Mapping

- **Host Port**: 5433 (your machine)
- **Container Port**: 5432 (inside Docker)
- **Local PostgreSQL**: 5432 (your existing installation - not affected)

### Why Port 5433?

If you have PostgreSQL installed locally on your machine, it typically uses port 5432. To avoid conflicts, this Odoo development environment uses port 5433 for the containerized PostgreSQL database.

### Connection Details

**For Odoo (automatic via odoo.conf):**
```
Host: localhost
Port: 5433
User: odoo
Password: odoo
Database: (created dynamically)
```

**For pgAdmin:**
- Web Interface: http://localhost:5050
- Login: admin@odoo.local / admin
- When adding server in pgAdmin:
  - Host: odoo18_postgres (container name)
  - Port: 5432 (internal Docker network)
  - Or from host: localhost / 5433

**For External Tools (DBeaver, DataGrip, etc.):**
```
Host: localhost
Port: 5433
User: odoo
Password: odoo
```

### Changing the Port

If you need to use a different port, edit the following files:

1. **`.env`** (or `.env.example`)
   ```bash
   POSTGRES_PORT=5434  # Change to your desired port
   ```

2. **`odoo.conf`**
   ```ini
   db_port = 5434
   ```

3. **`docker-compose.yml`**
   ```yaml
   ports:
     - "${POSTGRES_PORT:-5434}:5432"
   ```

Then restart the database:
```bash
docker-compose down
docker-compose up -d postgres
```

## Other Ports

### Odoo
- **Web Interface**: 8069
- **Longpolling**: 8072

Change in `.env`:
```bash
ODOO_PORT=8069
ODOO_LONGPOLLING_PORT=8072
```

### pgAdmin
- **Web Interface**: 5050

Change in `docker-compose.yml`:
```yaml
pgadmin:
  ports:
    - "5051:80"  # Change 5050 to your desired port
```

## Verifying Port Configuration

### Check PostgreSQL Port
```bash
docker-compose ps
# Should show: 0.0.0.0:5433->5432/tcp

# Test connection
docker exec odoo18_postgres psql -U odoo -d postgres -c "SELECT version();"
```

### Check if Port is in Use
```bash
# macOS/Linux
lsof -i :5433

# Check what's on default PostgreSQL port
lsof -i :5432
```

### Test Connection from Host
```bash
# Using psql (if installed locally)
psql -h localhost -p 5433 -U odoo -d postgres

# Or using Docker
docker exec -it odoo18_postgres psql -U odoo -d postgres
```

## Troubleshooting

### Port Already in Use
If you see "address already in use" error:

1. Find what's using the port:
   ```bash
   lsof -i :5433
   ```

2. Either stop that service or choose a different port

### Can't Connect to Database
```bash
# Check if container is running
docker-compose ps

# Check container logs
docker-compose logs postgres

# Restart database
docker-compose restart postgres
```

### Connection Refused
Make sure you're using the correct port:
- From host machine: `localhost:5433`
- From Odoo config: `localhost:5433`
- From inside Docker network: `odoo18_postgres:5432`

## Summary

✅ Your local PostgreSQL (port 5432) - **Unaffected**
✅ Docker PostgreSQL (port 5433) - **For Odoo development**
✅ Both can run simultaneously without conflicts
