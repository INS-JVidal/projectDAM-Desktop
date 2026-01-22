# EVALIS PostgreSQL Database Dockerfile
# Containerized PostgreSQL 14 with automatic EVALIS schema initialization
# Usage: docker build -t evalis-postgres:latest .

FROM postgres:14-alpine

# Set environment variables
# Note: POSTGRES_USER=postgres is the default superuser (created automatically)
# POSTGRES_DB=evalis_db creates the default database
# evalis_user role will be created by init scripts
ENV POSTGRES_DB=evalis_db \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=postgres \
    LANG=ca_ES.UTF-8 \
    LC_COLLATE=ca_ES.UTF-8 \
    LC_CTYPE=ca_ES.UTF-8 \
    PGDATA=/var/lib/postgresql/data/pgdata

# Install additional tools (optional, for debugging)
RUN apk add --no-cache \
    bash \
    curl

# Copy initialization scripts
# Scripts are run in alphabetical order by the PostgreSQL entrypoint
COPY database/init/*.sql /docker-entrypoint-initdb.d/

# Make sure scripts are executable and properly formatted for Unix
RUN chmod 755 /docker-entrypoint-initdb.d/*.sql && \
    dos2unix /docker-entrypoint-initdb.d/*.sql 2>/dev/null || true

# Expose PostgreSQL port
EXPOSE 5432

# Health check: Verify database is accepting connections
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD pg_isready -U evalis_user -d evalis_db || exit 1

# Default command (inherited from postgres:14-alpine)
CMD ["postgres"]
