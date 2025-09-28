# PostgreSQL Database

## Overview

PostgreSQL 16.4 serves as the primary relational database for Home Assistant's recorder component, storing real-time state changes, events, and statistics for home automation entities. This deployment is optimized for high-frequency time-series data with aggressive retention policies to maintain performance.

## Architecture

### Database Structure
- **Primary Database**: `homeassistant` (User: `ha`)
- **Current Size**: ~1.1GB (optimized from 14GB through aggressive data retention)
- **Container**: Running on Docker with persistent volume storage
- **Network**: Backend network with external port exposure (5432)

### Schema Components
The Home Assistant database contains the following core tables:
- **states**: Entity state changes (508MB)
- **state_attributes**: JSON attributes for states (582MB)
- **states_meta**: Entity metadata and identifiers
- **events**: Home automation events and triggers
- **event_data**: JSON data for events
- **statistics**: Long-term statistics aggregation
- **statistics_short_term**: 5-minute interval statistics
- **recorder_runs**: Database migration and run history

## Use Cases

### Primary Functions
1. **Home Assistant Recorder Backend**
   - Real-time state tracking for 500+ entities
   - Event logging for automations and scripts
   - Historical data for UI graphs and logbook
   - Statistics aggregation for energy dashboard

2. **Data Retention Strategy**
   - Short-term detailed states: 14 days
   - Long-term statistics: Indefinite
   - Excluded entities: Configuration parameters, LED settings
   - Focus on actionable data: Power, energy, motion, temperature

3. **Query Patterns**
   - High write volume: ~200K states/day (optimized from 3M+/day)
   - Frequent reads: Dashboard updates, history graphs
   - Bulk operations: Purge, statistics compilation

## Configuration

### PostgreSQL Tuning (`config/postgresql.conf`)

```ini
# Memory Configuration (1GB SHM allocated)
shared_buffers = 256MB              # 25% of available memory
work_mem = 16MB                     # Per-operation memory
maintenance_work_mem = 64MB         # VACUUM, CREATE INDEX operations
wal_buffers = 16MB                  # Write-ahead log buffer

# Autovacuum Settings (Aggressive for high-turnover tables)
autovacuum = on
autovacuum_naptime = 60s           # Check frequency
autovacuum_vacuum_scale_factor = 0.1    # Vacuum at 10% dead tuples
autovacuum_analyze_scale_factor = 0.05  # Analyze at 5% changes
autovacuum_max_workers = 3         # Parallel vacuum workers
autovacuum_vacuum_cost_delay = 20ms     # Throttling

# Checkpoint Configuration
checkpoint_timeout = 10min          # Force checkpoint interval
checkpoint_completion_target = 0.7  # Spread I/O load
max_wal_size = 1GB                  # Maximum WAL size between checkpoints

# Connection Settings
max_connections = 10                # Limited connections for Home Assistant
listen_addresses = '*'              # Allow network connections

# Logging
log_min_duration_statement = 1000  # Log slow queries (>1s)
log_checkpoints = on
log_autovacuum_min_duration = 0    # Log all autovacuum runs
```

### Network Access (`config/pg_hba.conf`)

```
# Allow internal network access
host    all             all             192.168.10.0/24         md5
# Docker network access
host    all             all             172.16.0.0/12          md5
```

### Docker Compose Configuration

```yaml
services:
  postgresql:
    image: postgres:16.4
    container_name: postgresql
    shm_size: 1gb                    # Increased shared memory
    environment:
      POSTGRES_DB: homeassistant
      POSTGRES_USER: ha
      POSTGRES_PASSWORD_FILE: /run/secrets/password
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - postgresql_data:/var/lib/postgresql/data
      - ./config/postgresql.conf:/etc/postgresql/postgresql.conf
      - ./config/pg_hba.conf:/var/lib/postgresql/data/pg_hba.conf
    ports:
      - '5432:5432'
    networks:
      - backend
```

## Home Assistant Integration

### Recorder Configuration
```yaml
# Home Assistant configuration.yaml
recorder:
  db_url: !secret postgres_url  # postgresql://ha:password@host:5432/homeassistant
  purge_keep_days: 14           # Retention period
  auto_purge: true              # Daily purge at 4:12 AM
  auto_repack: true             # Optimize storage
  commit_interval: 30           # Batch commits
  exclude:
    entity_globs:
      # Exclude noisy configuration entities
      - "number.*_defaultled*"
      - "number.*_brightnesslevel*"
      - "number.*_ramp*"
      - "sensor.*_linkquality"
    domains:
      - automation              # Don't track automation states
      - device_tracker         # Exclude device tracking
```

### Connection String Format
```
postgresql://ha:password@postgresql.backend:5432/homeassistant
```

## Maintenance

### Daily Operations
- **Automatic**: Autovacuum runs continuously
- **Purge**: Old states removed daily at 4:12 AM
- **Statistics**: Compiled every 5 minutes

### Monitoring Script
```bash
# Check database health
/home/docker/check_db_sizes.sh

# Manual VACUUM FULL (monthly recommended)
docker exec postgresql psql -U ha -d homeassistant -c "VACUUM FULL;"

# Analyze tables for query optimization
docker exec postgresql psql -U ha -d homeassistant -c "ANALYZE;"
```

### Backup Strategy
```bash
# Full database backup
docker exec postgresql pg_dump -U ha homeassistant | gzip > backup_$(date +%Y%m%d).sql.gz

# Restore from backup
gunzip -c backup.sql.gz | docker exec -i postgresql psql -U ha homeassistant
```

## Performance Optimization

### Storage Management
1. **Aggressive Exclusions**: Filter out configuration entities
2. **Retention Policy**: 14-day rolling window for detailed states
3. **Regular Maintenance**: Weekly VACUUM FULL recommended
4. **Index Management**: Automatic via autovacuum

### Query Optimization
- Indexes on: `metadata_id`, `last_updated_ts`, `entity_id`
- Partitioning considered for states table (future)
- Connection pooling through Home Assistant

### Troubleshooting

#### High Storage Usage
```sql
-- Check table sizes
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Find problematic entities
SELECT
  sm.entity_id,
  COUNT(*) as state_count
FROM states s
JOIN states_meta sm ON s.metadata_id = sm.metadata_id
WHERE s.last_updated_ts > EXTRACT(EPOCH FROM NOW() - INTERVAL '1 day')
GROUP BY sm.entity_id
ORDER BY state_count DESC
LIMIT 20;
```

#### Slow Queries
```sql
-- Enable query timing
\timing on

-- Check running queries
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';
```

## Security

### Authentication
- Password stored in Docker secrets: `${SECRETS}/postgress.password.ha`
- No default PostgreSQL user enabled
- Network access restricted to internal subnet

### Best Practices
1. Regular password rotation
2. Use read-only users for monitoring
3. Enable SSL for production (future enhancement)
4. Audit log reviews

## Integration with Other Services

### Current Integrations
- **Home Assistant**: Primary consumer via recorder
- **pgAdmin**: Web-based administration (optional)
- **Grafana**: Direct SQL queries for custom dashboards

### Future Considerations
- TimescaleDB extension for better time-series performance
- Read replicas for analytics workloads
- pg_stat_statements for query analysis

## Migration & Upgrades

### PostgreSQL Version Upgrades
```bash
# Backup before upgrade
docker exec postgresql pg_dumpall -U ha > full_backup.sql

# Stop container
docker-compose down

# Update image version in docker-compose.yaml
# Start new version
docker-compose up -d

# Verify upgrade
docker exec postgresql psql -U ha -c "SELECT version();"
```

### Home Assistant Migration
1. Stop Home Assistant
2. Backup database
3. Apply schema changes if needed
4. Restart Home Assistant
5. Verify recorder connection

## Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/16/)
- [Home Assistant Recorder](https://www.home-assistant.io/integrations/recorder/)
- [Docker PostgreSQL Image](https://hub.docker.com/_/postgres)
- [GitHub Repository](https://github.com/docker-library/postgres)

## Performance Metrics

### Current Statistics (Post-Optimization)
- Database Size: 1.1GB (92% reduction)
- Daily State Count: ~200K (95% reduction)
- Query Performance: <100ms average
- Autovacuum Frequency: Every 60 seconds
- Storage Growth: ~50MB/day

### Historical Context
- Previous Size: 14GB
- Previous State Rate: 3.7M records/day
- Optimization Date: 2025-09-28
- Primary Issue: Configuration entity pollution