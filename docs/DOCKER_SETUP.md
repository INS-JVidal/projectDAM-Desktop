# EVALIS Desktop - Docker Setup Guide

Complete guide for setting up and using Docker with the EVALIS Desktop application.

## Table of Contents

1. [Quick Start](#quick-start)
2. [System Requirements](#system-requirements)
3. [Installation](#installation)
4. [First-Time Setup](#first-time-setup)
5. [Daily Usage](#daily-usage)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Topics](#advanced-topics)
8. [FAQ](#faq)

## Quick Start

### Windows

1. **Install Docker Desktop**
   - Download from: https://www.docker.com/products/docker-desktop/
   - Follow the installation wizard
   - Restart your computer

2. **Clone the Repository**
   ```powershell
   git clone <repository-url>
   cd DESKTOP_EVALIS
   ```

3. **Run the Application**
   ```powershell
   cd Evalis-Desktop
   # Open Evalis-Desktop.sln in Visual Studio
   # Or run: dotnet run --project Evalis-Desktop.vbproj
   ```

4. **Application Startup**
   - The VB.NET application will automatically:
     - Detect if Docker is installed
     - Start Docker Desktop if needed
     - Start the PostgreSQL container if not running
     - Initialize the database with all tables and seed data
     - Display login screen

### Linux / WSL2

1. **Install Docker**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install docker.io docker-compose

   # Add user to docker group (to avoid sudo)
   sudo usermod -aG docker $USER
   newgrp docker
   ```

2. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd DESKTOP_EVALIS
   ```

3. **Start Database (optional)**
   ```bash
   cd database/docker
   ./start-database.sh
   ```

4. **Run Application**
   ```bash
   cd Evalis-Desktop
   dotnet run --project Evalis-Desktop.vbproj
   ```

## System Requirements

### Hardware

- **CPU**: 2+ cores
- **RAM**: 4+ GB (8 GB recommended)
- **Disk Space**: 2+ GB free

### Software

#### Windows

- **Docker Desktop**: v20.10+ for Windows 10/11
  - WSL2 backend (recommended for better performance)
  - Alternative: Hyper-V backend
- **.NET**: .NET 8.0 SDK or Runtime
- **Visual Studio**: 2022 Community Edition (optional, for development)

#### Linux

- **Docker Engine**: v20.10+
- **docker-compose**: v1.29+ or Docker Compose v2+
- **.NET**: .NET 8.0 SDK or Runtime

#### macOS

- **Docker Desktop for Mac**: v20.10+
- **.NET**: .NET 8.0 SDK or Runtime

## Installation

### Docker Desktop Installation (Windows)

**Step 1: Download**
1. Go to https://www.docker.com/products/docker-desktop/
2. Click "Download for Windows"
3. Choose appropriate installer:
   - Intel/AMD Processor: `Docker Desktop Installer.exe`
   - Apple Silicon: N/A (Windows-only, not supported on macOS via WSL)

**Step 2: Install**
1. Double-click the installer
2. Follow the installation wizard
3. When prompted, enable:
   - ☑ WSL2 Windows Subsystem for Linux
   - ☑ Hyper-V (if WSL2 unavailable)
4. Complete installation and restart computer

**Step 3: Verify Installation**
```powershell
docker --version
docker ps
```

Should show:
```
Docker version X.XX.X, build XXXXX
CONTAINER ID   IMAGE   COMMAND   CREATED   STATUS   PORTS   NAMES
```

### Docker Engine Installation (Linux)

**Ubuntu/Debian:**
```bash
# Update package index
sudo apt-get update

# Install Docker
sudo apt-get install docker.io docker-compose

# Enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (optional, avoids needing sudo)
sudo usermod -aG docker $USER

# Apply group changes (in new terminal or use: newgrp docker)
newgrp docker

# Verify installation
docker --version
docker ps
```

**Fedora/RHEL:**
```bash
sudo dnf install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
```

### Docker Desktop Installation (macOS)

1. Download from: https://www.docker.com/products/docker-desktop/
2. Choose installer based on processor:
   - Intel: `Docker.dmg`
   - Apple Silicon (M1/M2): `Docker.dmg` (universal binary)
3. Drag `Docker.app` to Applications folder
4. Open Applications and launch Docker
5. Verify: `docker --version`

## First-Time Setup

### Automated Setup (Recommended)

Just run the VB.NET application - everything is automatic!

1. **Open Visual Studio**
   - File → Open → Project/Solution
   - Navigate to `Evalis-Desktop/Evalis-Desktop.sln`

2. **Press F5 to Run**
   - Application will check for Docker
   - Docker Desktop will launch automatically (if not running)
   - Container will start automatically
   - Database will initialize with all tables and seed data
   - Login screen will appear

3. **Login**
   - Use demo account: `cap_estudis` / `Test1234`
   - Or: `prof_test` / `Test1234`
   - Or: `tutor_dam2` / `Test1234`

### Manual Setup

If you prefer to start Docker manually:

**Windows (PowerShell):**
```powershell
cd database/docker
.\start-database.ps1
```

**Linux/WSL (Bash):**
```bash
cd database/docker
./start-database.sh
```

**macOS (Bash):**
```bash
cd database/docker
./start-database.sh
```

## Daily Usage

### Starting the Application

**Windows (Visual Studio):**
1. Open `Evalis-Desktop.sln` in Visual Studio
2. Press F5 or Debug → Start Debugging
3. Application will auto-start Docker and database
4. Login screen appears in ~10-30 seconds (depending on Docker startup)

**Windows (Command Line):**
```powershell
cd Evalis-Desktop
dotnet run --project Evalis-Desktop.vbproj
```

**Linux/macOS:**
```bash
cd Evalis-Desktop
dotnet run --project Evalis-Desktop.vbproj
```

### Stopping the Application

Simply close the application window. The database container will continue running in the background.

### Pausing Development

To stop the database (and free up system resources):

**Windows (PowerShell):**
```powershell
cd database/docker
.\stop-database.ps1
```

**Linux/macOS:**
```bash
cd database/docker
./stop-database.sh
```

### Checking Database Status

**From PowerShell/Bash:**
```bash
# Check if container is running
docker ps

# Check all containers (including stopped)
docker ps -a

# View container logs
docker logs evalis-db --tail 50 -f
```

## Troubleshooting

### Docker Not Found

**Problem**: "Docker not found" or "Docker is not installed"

**Solution**:
1. Download Docker Desktop: https://www.docker.com/products/docker-desktop/
2. Install following the Windows/Linux/macOS instructions above
3. Restart your computer
4. Restart the application

**Windows-Specific**:
- If using PowerShell, try using Command Prompt instead
- Try running PowerShell as Administrator
- Restart Docker Desktop from system tray

### Docker Daemon Not Running

**Problem**: "Docker daemon not running" or "Cannot connect to Docker daemon"

**Solution**:

**Windows**:
1. Click Docker icon in system tray
2. If not visible, open Start menu and type "Docker"
3. Click "Docker Desktop" to start it
4. Wait 30-60 seconds for startup
5. Retry application

**Linux**:
```bash
# Check Docker status
systemctl status docker

# Start Docker if stopped
sudo systemctl start docker

# Enable auto-start
sudo systemctl enable docker
```

### Container Fails to Start

**Problem**: Container starts but database not responding

**Solution**:

1. **Check logs**:
   ```bash
   docker logs evalis-db --tail 100
   ```

2. **Check if port 5432 is in use**:
   ```powershell
   # Windows
   netstat -ano | findstr :5432
   ```

   ```bash
   # Linux/macOS
   lsof -i :5432
   ```

3. **Free the port or use different port**:
   - Stop conflicting PostgreSQL: `docker stop <container-name>`
   - Or edit `docker-compose.yml` to use different port: `"5433:5432"`

4. **Restart container**:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Database Initialization Takes Too Long

**Problem**: Application shows "Waiting for database..." for more than 2 minutes

**Solution**:

1. Check available system resources:
   - RAM usage (Docker needs ~1 GB)
   - Disk space (needs ~500 MB free)
   - CPU usage

2. Check container logs for errors:
   ```bash
   docker logs evalis-db --tail 50
   ```

3. Increase timeout in `docker.config`:
   ```xml
   <add key="StartupTimeoutSeconds" value="300" />
   ```

### Login Fails After Database Starts

**Problem**: Database running but login fails with "Connection error"

**Possible Solutions**:

1. **Check database connection**:
   ```bash
   docker exec evalis-db psql -U evalis_user -d evalis_db -c "SELECT 1;"
   ```

2. **Verify tables exist**:
   ```bash
   docker exec evalis-db psql -U evalis_user -d evalis_db -c "\dt"
   ```

3. **Check application logs** (if any):
   - Windows Event Viewer
   - Application debug output in Visual Studio

4. **Check credentials** in `Config/database.config`:
   - Username: `evalis_user`
   - Password: `evalis2024`
   - Database: `evalis_db`
   - Port: `5432`

5. **Reinitialize database**:
   ```bash
   docker-compose down -v  # WARNING: Deletes all data
   docker-compose up -d
   ```

### Application Crashes on Startup

**Problem**: Application crashes with error message

**Solution**:

1. **Check .NET installation**:
   ```bash
   dotnet --version
   ```

2. **Restore NuGet packages**:
   ```bash
   cd Evalis-Desktop
   dotnet restore
   ```

3. **Clean and rebuild**:
   ```bash
   dotnet clean
   dotnet build
   ```

4. **View detailed error logs**:
   - In Visual Studio: Debug output window
   - In command line: Run with verbose logging

## Advanced Topics

### Connecting with External Tools

You can connect to the Docker database using database clients:

**Connection Parameters**:
- Host: `localhost`
- Port: `5432`
- Database: `evalis_db`
- Username: `evalis_user`
- Password: `evalis2024`

**pgAdmin (Web Interface)**:
```bash
# Add pgAdmin container to docker-compose.yml
# Then access at http://localhost:5050
```

**DBeaver (Desktop Client)**:
1. Download from https://dbeaver.io/
2. New Database Connection
3. PostgreSQL
4. Enter connection details above

**psql (Command Line)**:
```bash
docker exec -it evalis-db psql -U evalis_user -d evalis_db

# Inside psql:
\dt              # List tables
\d users         # Describe users table
SELECT * FROM users;  # Query data
\q              # Exit
```

### Backing Up Database

**Create Backup**:
```bash
docker exec evalis-db pg_dump -U evalis_user -d evalis_db > backup_$(date +%Y%m%d_%H%M%S).sql
```

**Restore from Backup**:
```bash
# Option 1: To running container
docker exec -i evalis-db psql -U evalis_user -d evalis_db < backup_YYYYMMDD_HHMMSS.sql

# Option 2: Create fresh container and restore
docker-compose down -v
docker-compose up -d
# Wait for initialization
docker exec -i evalis-db psql -U evalis_user -d evalis_db < backup_YYYYMMDD_HHMMSS.sql
```

### Monitoring Container

**View Container Metrics**:
```bash
# Memory and CPU usage
docker stats evalis-db

# Detailed inspection
docker inspect evalis-db

# Health status
docker inspect --format='{{json .State.Health}}' evalis-db | jq
```

### Custom Configuration

Edit `database/docker/docker-compose.yml` to customize:

**Change Port**:
```yaml
ports:
  - "5433:5432"  # Use port 5433 instead of 5432
```

**Change Password** (development only):
```yaml
environment:
  POSTGRES_PASSWORD: your_new_password
```

Then update `Config/database.config` to match.

**Increase Memory Limit**:
```yaml
deploy:
  resources:
    limits:
      memory: 2G
```

### Production Deployment

For production use:

1. **Change default password**:
   - Edit `docker-compose.yml`
   - Use strong password
   - Store in environment variable or secrets manager

2. **Use persistent backups**:
   - Set up automated backups
   - Store backups in secure location

3. **Enable SSL**:
   - Add certificate to container
   - Update connection string with SSL mode

4. **Use managed database** (recommended):
   - Consider cloud-hosted PostgreSQL (AWS RDS, Azure Database, etc.)
   - Eliminates need for Docker database management

## FAQ

### Q: Can I use PostgreSQL installed locally instead of Docker?

**A**: Yes. The VB.NET application doesn't require Docker. If you have local PostgreSQL:

1. Skip Docker installation
2. Manually initialize database with SQL scripts in `database/init/`
3. Update connection string in `Config/database.config`
4. Modify `ApplicationEvents.vb` to skip Docker check

However, Docker is recommended for:
- Consistency across machines
- No local installation required
- Easy reset/clean database
- Better isolation

### Q: What happens to my data if I stop the container?

**A**: Data is preserved in the persistent Docker volume. When you restart the container, all data is restored automatically. Data is only lost if you explicitly delete the volume with `docker-compose down -v`.

### Q: Can multiple developers share the same database?

**A**: Currently, each developer has their own Docker container (isolated). To share a database:

1. Run Docker on a shared server/machine
2. Configure connection string to point to that server
3. Consider using cloud database (AWS RDS, Azure, etc.)

### Q: How do I update the database schema?

**A**:

1. **For development** (safe to lose data):
   - Add new SQL files to `database/init/`
   - Reinitialize: `docker-compose down -v && docker-compose up -d`

2. **For production** (preserve data):
   - Create migration SQL script
   - Execute manually against running database
   - Test thoroughly before deploying

### Q: How much disk space does Docker use?

**A**:
- Base image: ~50 MB
- Data volume (empty): ~30 MB
- With seed data: ~100-200 MB

### Q: Can I run this on macOS?

**A**: Yes! Install Docker Desktop for Mac and follow the setup instructions. The application works on Mac for development, but final deployment is typically on Windows for Windows Forms applications.

### Q: What if I accidentally delete the Docker volume?

**A**: Don't worry! The container will automatically reinitialize on next start with fresh database schema and seed data. Your data will be lost, but the database structure will be perfect.

To intentionally reset:
```bash
docker-compose down -v
docker-compose up -d
```

### Q: How do I view the database graphically?

**A**: Use pgAdmin (web interface) or DBeaver (desktop client). See [Connecting with External Tools](#connecting-with-external-tools) section.

### Q: Can I use different PostgreSQL version?

**A**: Yes, edit the Dockerfile:
```dockerfile
FROM postgres:15-alpine  # Change version
```

Then rebuild: `docker-compose build`

Note: Different versions may have compatibility differences. Version 14+ recommended.

### Q: How do I troubleshoot slow performance?

**A**:

1. Check system resources:
   ```bash
   docker stats evalis-db
   ```

2. Check database size:
   ```bash
   docker exec evalis-db psql -U evalis_user -d evalis_db -c "SELECT pg_size_pretty(pg_database_size('evalis_db'));"
   ```

3. Monitor queries:
   ```bash
   docker exec evalis-db psql -U evalis_user -d evalis_db -c "SELECT * FROM pg_stat_activity WHERE state != 'idle';"
   ```

4. Consider:
   - Upgrading RAM
   - Increasing Docker memory limit
   - Optimizing queries/indexes
   - Using SSD instead of HDD

## Getting Help

If you encounter issues:

1. Check [Troubleshooting](#troubleshooting) section
2. Review container logs: `docker logs evalis-db`
3. Check Docker Desktop logs (Windows: View Diagnostics)
4. Report issue on GitHub with logs and error messages

## Next Steps

- See [CLAUDE.md](../CLAUDE.md) for project architecture
- See [database/docker/README.md](../database/docker/README.md) for Docker technical details
- See [desktop_evalis_PPD.md](../desktop_evalis_PPD.md) for project specification
