# EVALIS PostgreSQL Docker Container

This directory contains Docker configuration for containerizing the EVALIS PostgreSQL database.

## Quick Start

### Prerequisites

- Docker Desktop for Windows/Mac or Docker Engine for Linux
- [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)

### Start the Database

**PowerShell (Windows):**
```powershell
cd database/docker
.\start-database.ps1
```

**Bash (WSL2 or Linux):**
```bash
cd database/docker
./start-database.sh
```

**Manual (any platform):**
```bash
docker-compose up -d
```

### Stop the Database

**PowerShell:**
```powershell
.\stop-database.ps1
```

**Bash:**
```bash
./stop-database.sh
```

**Manual:**
```bash
docker-compose down
```

## Docker Container Details

### Container Information

- **Container Name**: `evalis-db`
- **Image Name**: `evalis-postgres:latest`
- **Base Image**: `postgres:14-alpine`
- **Port**: `5432` (exposed to localhost only)
- **Data Directory**: `/var/lib/postgresql/data`

### Connection Details

| Property | Value |
|----------|-------|
| **Host** | `localhost` |
| **Port** | `5432` |
| **Database** | `evalis_db` |
| **Username** | `evalis_user` |
| **Password** | `evalis2024` |

**Connection String:**
```
postgresql://evalis_user:evalis2024@localhost:5432/evalis_db
```

## Database Initialization

On first run, the container automatically initializes the database with all EVALIS schema:

### Initialization Scripts (executed in order)

| Script | Purpose |
|--------|---------|
| `00_create_database.sql` | Create database and extensions |
| `01_create_schemas.sql` | Create schema structure |
| `02_create_tables.sql` | Create core tables |
| `03_create_indexes.sql` | Create indexes for performance |
| `04_create_functions.sql` | Create PL/pgSQL functions |
| `05_seed_data.sql` | Insert initial data |
| `06_phase2_academic_tables.sql` | Phase 2 academic tables |
| `07_phase2_indexes.sql` | Phase 2 indexes |
| `08_phase3_extended_tables.sql` | Phase 3 extended tables |
| `09_phase3_indexes.sql` | Phase 3 indexes |
| `10_business_logic_functions.sql` | Business logic functions |
| `11_seed_data_academic.sql` | Academic seed data |
| `12_seed_data_extended.sql` | Extended seed data |

## Docker Compose Commands

### Build the Image

```bash
docker-compose build
```

Creates a Docker image from the Dockerfile.

### Start Container (detached)

```bash
docker-compose up -d
```

Starts the container in background mode.

### View Logs

```bash
docker-compose logs -f evalis-postgres
```

View real-time logs. Press `Ctrl+C` to exit.

### Check Container Status

```bash
docker ps
```

Lists running containers.

### Access Database Directly

```bash
docker exec -it evalis-db psql -U evalis_user -d evalis_db
```

Opens an interactive PostgreSQL shell inside the container.

### Stop Container

```bash
docker-compose down
```

Stops and removes the container (data preserved in volume).

### Stop and Remove Everything

```bash
docker-compose down -v
```

**WARNING**: Removes both container AND the persistent volume. All data is deleted.

## Volume Management

### Data Persistence

Database data is stored in a Docker named volume `evalis_postgres_data`. This volume persists across:
- Container restarts
- Image rebuilds
- Docker daemon restarts

Data is only lost if you explicitly delete the volume:
```bash
docker volume rm evalis_postgres_data
```

### Backup Database

**Create a backup dump:**

```bash
docker exec evalis-db pg_dump -U evalis_user -d evalis_db > backup_$(date +%Y%m%d_%H%M%S).sql
```

**Restore from backup:**

```bash
# Stop the running container
docker-compose down

# Delete the old volume
docker volume rm evalis_postgres_data

# Start fresh (creates new volume)
docker-compose up -d

# Wait for initialization, then restore
docker exec -i evalis-db psql -U evalis_user -d evalis_db < backup_YYYYMMDD_HHMMSS.sql
```

### Export Volume to Host

```bash
# Create a temporary container to access volume
docker run --rm -v evalis_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-data.tar.gz -C /data .

# Restore from archive
docker volume create evalis_postgres_data
docker run --rm -v evalis_postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres-data.tar.gz -C /data
```

## Health Checks

The container includes automatic health checks via `pg_isready`.

### Check Container Health

```bash
docker inspect --format='{{json .State.Health.Status}}' evalis-db
```

Response values:
- `"healthy"` - Database is ready
- `"unhealthy"` - Database failed health checks
- `"starting"` - Still initializing

### Wait for Database Ready

```bash
# Keep checking until database is ready
docker exec evalis-db pg_isready -U evalis_user -d evalis_db

# Exit code 0 = ready, 1 = not ready
```

## Troubleshooting

### Container Fails to Start

**Check logs:**
```bash
docker-compose logs evalis-postgres
```

**Common issues:**
- Port 5432 already in use: Stop conflicting PostgreSQL service or change port in `docker-compose.yml`
- Insufficient disk space: Free up disk space
- Permission issues: Run with appropriate permissions

### Connection Refused

**Verify container is running:**
```bash
docker ps | grep evalis-db
```

**Verify health status:**
```bash
docker inspect --format='{{json .State.Health}}' evalis-db
```

**Wait for startup:**
Container initialization takes 30-60 seconds. If recently started, wait and retry.

### Check Database Contents

```bash
# List tables
docker exec evalis-db psql -U evalis_user -d evalis_db -c "\dt"

# Count rows
docker exec evalis-db psql -U evalis_user -d evalis_db -c "SELECT COUNT(*) FROM users;"

# Query data
docker exec evalis-db psql -U evalis_user -d evalis_db -c "SELECT * FROM users;"
```

### Reinitialize Database

```bash
# Stop and remove everything
docker-compose down -v

# Start fresh (will reinitialize)
docker-compose up -d
```

## Performance Tuning

### Increase Memory

Edit `docker-compose.yml` and add:
```yaml
environment:
  POSTGRES_INIT_ARGS: "-c shared_buffers=256MB -c effective_cache_size=512MB"
```

### View Running Queries

```bash
docker exec evalis-db psql -U evalis_user -d evalis_db -c "SELECT * FROM pg_stat_activity WHERE state != 'idle';"
```

### Database Size

```bash
docker exec evalis-db psql -U evalis_user -d evalis_db -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database;"
```

## Security Notes

### Default Credentials

⚠️ **Development Only**: Default password `evalis2024` is suitable only for development.

**For Production:**
1. Change `POSTGRES_PASSWORD` in `docker-compose.yml`
2. Store password in `.env` file (don't commit to git)
3. Update connection strings in application
4. Consider using Docker secrets

### Port Binding

Current configuration binds only to `localhost:5432` (secure by default).

To expose to network:
```yaml
ports:
  - "0.0.0.0:5432:5432"  # WARNING: Exposes database to network
```

### User Permissions

The PostgreSQL container runs as unprivileged user inside the container (secure by default).

## Integration with VB.NET Application

The VB.NET application automatically manages the Docker container:

1. **Startup**: Checks if Docker and container are running
2. **Auto-Start**: Starts Docker Desktop and container if needed
3. **Health Check**: Monitors database connectivity
4. **Error Handling**: Shows clear error messages if Docker unavailable

No manual Docker commands needed for normal application usage.

## FAQ

### Q: How do I connect from a different machine?

**A:** Currently, the container binds only to `localhost`. To connect from another machine:

1. Edit `docker-compose.yml` port mapping:
   ```yaml
   ports:
     - "0.0.0.0:5432:5432"
   ```

2. Use machine's IP address in connection string

3. **Security Warning**: This exposes the database to your network.

### Q: Can I use a different PostgreSQL version?

**A:** Yes, edit the base image in `Dockerfile`:
```dockerfile
FROM postgres:15-alpine  # or 12, 13, 16, etc.
```

Then rebuild: `docker-compose build`

### Q: How much disk space does it use?

**A:** Approximately:
- Image: 50-100 MB
- Data volume (empty): 30 MB
- Data volume (with seed data): 100-200 MB

### Q: Can I run multiple instances?

**A:** Yes, create separate docker-compose files with different container names and ports:
```yaml
container_name: evalis-db-dev
ports:
  - "5432:5432"
```

```yaml
container_name: evalis-db-test
ports:
  - "5433:5432"
```

### Q: How do I update the schema?

**A:** Add new SQL files to `database/init/` directory (numbering after existing files) and rebuild:
```bash
docker-compose down -v
docker-compose build
docker-compose up -d
```

## References

- [PostgreSQL Official Docker Image](https://hub.docker.com/_/postgres)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL CLI Tools](https://www.postgresql.org/docs/14/reference-client.html)
- [pg_isready Manual](https://www.postgresql.org/docs/14/app-pg-isready.html)
