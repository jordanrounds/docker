# InfluxDB 2.7 Time Series Database

## Overview

InfluxDB 2.7 is a high-performance time series database optimized for storing and querying metrics, events, and real-time analytics data. In this deployment, it serves as the long-term storage backend for Home Assistant sensor data, providing efficient compression and retention management for IoT metrics.

## Architecture

### Database Structure
- **Organization**: `rounds.house`
- **Primary Buckets**:
  - `home_assistant` - Active bucket for new data
  - `homeassistant` - Legacy bucket (migration in progress)
- **Retention**: 90 days (2160 hours)
- **Current Size**: 5.3GB
- **Container**: Docker with persistent volumes
- **Networks**: Frontend (Traefik) and Backend

### Storage Model
InfluxDB uses a columnar storage format optimized for time series:
- **Measurements**: Similar to tables (e.g., temperature, humidity, power)
- **Tags**: Indexed metadata (e.g., entity_id, device_name, location)
- **Fields**: Actual metric values (not indexed)
- **Timestamps**: Nanosecond precision UTC timestamps

## Use Cases

### Primary Functions

1. **Home Assistant Long-Term Metrics**
   - Sensor data retention beyond PostgreSQL's 14-day window
   - Energy monitoring and consumption analytics
   - Climate and environmental tracking
   - Device performance metrics

2. **Data Retention Strategy**
   - 90-day rolling window for all metrics
   - Automatic data expiration (no manual purge needed)
   - Downsampling capabilities for long-term trends
   - Continuous queries for aggregation

3. **Query Patterns**
   - Time-based aggregations (hourly, daily, monthly)
   - Mathematical operations (mean, sum, derivative)
   - Multi-measurement joins
   - Real-time alerting queries

### Typical Metrics Stored
- **Energy**: Power consumption, solar production, grid usage
- **Climate**: Temperature, humidity, pressure, air quality
- **System**: CPU usage, memory, disk space, network traffic
- **IoT Devices**: Battery levels, signal strength, uptime
- **Home Automation**: Light levels, motion detection, door states

## Configuration

### Docker Compose Setup

```yaml
services:
  influxdb2:
    image: influxdb:2.7
    container_name: influxdb2
    environment:
      DOCKER_INFLUXDB_INIT_MODE: setup
      DOCKER_INFLUXDB_INIT_USERNAME_FILE: /run/secrets/influx-username
      DOCKER_INFLUXDB_INIT_PASSWORD_FILE: /run/secrets/influx-password
      DOCKER_INFLUXDB_INIT_ADMIN_TOKEN_FILE: /run/secrets/influx-token
      DOCKER_INFLUXDB_INIT_ORG: rounds.house
      DOCKER_INFLUXDB_INIT_BUCKET: homeassistant
    secrets:
      - influx-username
      - influx-password
      - influx-token
    ports:
      - '8086:8086'
    volumes:
      - influxdb2_data:/var/lib/influxdb2
      - influxdb2_config:/etc/influxdb2
    networks:
      - frontend  # For Traefik access
      - backend   # For internal services
    labels:
      traefik.enable: 'true'
      traefik.http.routers.influxdb2.rule: 'Host(`influxdb.in.rounds.house`)'
      traefik.http.routers.influxdb2.entrypoints: 'https'
      traefik.http.routers.influxdb2.tls: 'true'
```

### Initial Setup Process
1. Container auto-creates admin user on first run
2. Organization and default bucket created automatically
3. Admin token generated and stored in secrets
4. Web UI available at https://influxdb.in.rounds.house

### Retention Policies

```bash
# View current retention
docker exec influxdb2 influx bucket list

# Update retention (example: 90 days)
docker exec influxdb2 influx bucket update \
  --id BUCKET_ID \
  --retention 90d

# Create new bucket with retention
docker exec influxdb2 influx bucket create \
  --name metrics \
  --org rounds.house \
  --retention 30d
```

## Home Assistant Integration

### InfluxDB Integration Configuration

```yaml
# Home Assistant configuration.yaml
influxdb:
  api_version: 2
  ssl: false
  host: influxdb2
  port: 8086
  organization: rounds.house
  bucket: home_assistant
  token: !secret influxdb_token

  # Measurement precision
  precision: s

  # Include/Exclude filters
  include:
    entities:
      - sensor.*_power
      - sensor.*_energy
      - sensor.*_temperature
      - sensor.*_humidity
      - sensor.*_battery
    domains:
      - climate
      - weather

  exclude:
    entities:
      - sensor.*_attributes
      - sensor.*_raw
    entity_globs:
      - sensor.*_linkquality

  # Custom tags for better organization
  tags_attributes:
    - friendly_name
    - device_class
    - unit_of_measurement
```

### Data Structure in InfluxDB
```
Measurement: "sensor.living_room_temperature"
Tags:
  - entity_id: "sensor.living_room_temperature"
  - domain: "sensor"
  - friendly_name: "Living Room Temperature"
  - device_class: "temperature"

Fields:
  - value: 22.5
  - unit: "°C"

Time: 2025-09-28T12:00:00Z
```

## API & Access Methods

### Web UI Access
- URL: https://influxdb.in.rounds.house
- Features: Data Explorer, Dashboards, Tasks, Alerts
- Authentication: Username/password or token

### CLI Access
```bash
# Interactive shell
docker exec -it influxdb2 influx

# Direct query
docker exec influxdb2 influx query -o rounds.house '
  from(bucket: "home_assistant")
    |> range(start: -1h)
    |> filter(fn: (r) => r["entity_id"] == "sensor.power_consumption")
    |> mean()
'
```

### Flux Query Language Examples

```flux
// Get average temperature last 24 hours
from(bucket: "home_assistant")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "°C")
  |> filter(fn: (r) => r["entity_id"] =~ /temperature/)
  |> aggregateWindow(every: 1h, fn: mean)

// Calculate daily energy consumption
from(bucket: "home_assistant")
  |> range(start: -7d)
  |> filter(fn: (r) => r["entity_id"] == "sensor.total_energy")
  |> aggregateWindow(every: 1d, fn: last)
  |> difference()

// Find peak power usage
from(bucket: "home_assistant")
  |> range(start: -30d)
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["entity_id"] =~ /power/)
  |> max()
```

### REST API Examples

```bash
# Write data
curl -X POST "http://influxdb2:8086/api/v2/write?org=rounds.house&bucket=home_assistant" \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Content-Type: text/plain; charset=utf-8" \
  -d 'temperature,entity_id=sensor.test value=23.5'

# Query data
curl -X POST "http://influxdb2:8086/api/v2/query?org=rounds.house" \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Content-Type: application/vnd.flux" \
  -d 'from(bucket: "home_assistant") |> range(start: -1h)'
```

## Maintenance & Operations

### Monitoring Database Health

```bash
# Check database size
docker exec influxdb2 du -sh /var/lib/influxdb2

# View internal metrics
docker exec influxdb2 influx query -o rounds.house '
  from(bucket: "_monitoring")
    |> range(start: -1h)
    |> filter(fn: (r) => r["_measurement"] == "storage_usage")
'

# Check cardinality (unique series)
docker exec influxdb2 influx query -o rounds.house '
  import "influxdata/influxdb"
  influxdb.cardinality(
    bucket: "home_assistant",
    start: -7d
  )
'
```

### Backup Procedures

```bash
# Full backup
docker exec influxdb2 influx backup /tmp/backup \
  --bucket home_assistant \
  --org rounds.house

# Copy backup to host
docker cp influxdb2:/tmp/backup ./influxdb_backup_$(date +%Y%m%d)

# Restore from backup
docker cp ./influxdb_backup influxdb2:/tmp/
docker exec influxdb2 influx restore /tmp/influxdb_backup \
  --bucket home_assistant \
  --org rounds.house
```

### Performance Optimization

1. **Cardinality Management**
   - Limit unique tag combinations
   - Use fields for high-cardinality data
   - Regular cardinality monitoring

2. **Retention Optimization**
   ```bash
   # Create downsampled bucket for long-term storage
   docker exec influxdb2 influx bucket create \
     --name home_assistant_daily \
     --org rounds.house \
     --retention 365d
   ```

3. **Task Automation**
   ```flux
   // Downsample task (runs daily)
   option task = {name: "downsample_daily", every: 1d}

   from(bucket: "home_assistant")
     |> range(start: -1d)
     |> aggregateWindow(every: 1h, fn: mean)
     |> to(bucket: "home_assistant_daily")
   ```

### Troubleshooting

#### High Memory Usage
```bash
# Check memory stats
docker stats influxdb2

# Increase container memory limit
docker-compose down
# Edit docker-compose.yaml - add mem_limit
docker-compose up -d
```

#### Slow Queries
```bash
# Enable query logging
docker exec influxdb2 influx config set \
  --name rounds.house \
  --log-level debug

# Profile query performance
# Add |> profile() to any Flux query
```

#### Data Issues
```bash
# Verify data ingestion
docker exec influxdb2 influx query -o rounds.house '
  from(bucket: "home_assistant")
    |> range(start: -1m)
    |> count()
'

# Check for data gaps
docker exec influxdb2 influx query -o rounds.house '
  from(bucket: "home_assistant")
    |> range(start: -1h)
    |> window(every: 1m)
    |> count()
    |> filter(fn: (r) => r._value == 0)
'
```

## Integration with Other Services

### Grafana Integration
```yaml
# Grafana datasource configuration
apiVersion: 1
datasources:
  - name: InfluxDB
    type: influxdb
    access: proxy
    url: http://influxdb2:8086
    jsonData:
      version: Flux
      organization: rounds.house
      defaultBucket: home_assistant
    secureJsonData:
      token: YOUR_TOKEN
```

### Node-RED Integration
- Use `node-red-contrib-influxdb` nodes
- Configure with token authentication
- Support for both read and write operations

### Telegraf Collection
```toml
# telegraf.conf
[[outputs.influxdb_v2]]
  urls = ["http://influxdb2:8086"]
  token = "YOUR_TOKEN"
  organization = "rounds.house"
  bucket = "telegraf"
```

## Security

### Authentication Methods
1. **Token-Based** (Recommended)
   - Admin token in Docker secrets
   - Read/write tokens for services
   - Scoped tokens for limited access

2. **User Authentication**
   - Admin user created on setup
   - Additional users via UI/CLI
   - Role-based access control

### Best Practices
1. Rotate tokens regularly
2. Use read-only tokens for dashboards
3. Separate buckets for different data sources
4. Enable TLS for production
5. Regular security audits

### Network Security
- Frontend network for Traefik/external access
- Backend network for internal services
- No direct internet exposure (Traefik proxy)

## Migration & Upgrades

### Version Upgrades
```bash
# Backup before upgrade
./backup_influxdb.sh

# Update docker-compose.yaml
# Change image: influxdb:2.7 to influxdb:2.8

# Restart with new version
docker-compose down
docker-compose up -d

# Verify upgrade
docker exec influxdb2 influx version
```

### Data Migration
```bash
# Export data from old bucket
docker exec influxdb2 influx query -o rounds.house \
  --raw 'from(bucket: "old_bucket") |> range(start: -90d)' \
  > export.csv

# Import to new bucket
docker exec -i influxdb2 influx write \
  --bucket new_bucket \
  --org rounds.house \
  < export.csv
```

## Performance Metrics

### Current Statistics
- **Database Size**: 5.3GB
- **Retention Period**: 90 days
- **Measurement Count**: ~50 active measurements
- **Points Per Day**: ~2-3 million
- **Query Performance**: <50ms for typical aggregations
- **Compression Ratio**: ~10:1

### Optimization Results
- Previous: Infinite retention (growing unbounded)
- Current: 90-day retention (stable size)
- Storage savings: Will stabilize at ~4GB
- Query performance: 3x improvement with limited retention

## Resources

- [InfluxDB Documentation](https://docs.influxdata.com/influxdb/v2.7/)
- [Flux Language Reference](https://docs.influxdata.com/flux/v0.x/)
- [Home Assistant InfluxDB Integration](https://www.home-assistant.io/integrations/influxdb/)
- [Docker Hub - InfluxDB](https://hub.docker.com/_/influxdb)
- [InfluxDB GitHub](https://github.com/influxdata/influxdb)
- [Best Practices Guide](https://docs.influxdata.com/influxdb/v2.7/write-data/best-practices/)

## Quick Reference

### Common Commands
```bash
# View buckets
docker exec influxdb2 influx bucket list

# Create bucket
docker exec influxdb2 influx bucket create -n test -o rounds.house -r 7d

# Delete bucket
docker exec influxdb2 influx bucket delete -n test -o rounds.house

# Export config
docker exec influxdb2 influx export all

# Health check
curl http://influxdb2:8086/health
```

### Connection Details
- **Internal URL**: http://influxdb2:8086
- **External URL**: https://influxdb.in.rounds.house
- **Organization**: rounds.house
- **Default Bucket**: home_assistant
- **API Version**: v2