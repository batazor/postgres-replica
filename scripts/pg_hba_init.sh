#!/bin/bash

# Variables
PG_HBA_CONF_PATH="/var/lib/postgresql/data/pg_hba.conf"
NEW_ENTRY="host    replication     all             0.0.0.0/0               md5"

# Function to check if the replication line already exists
if grep -Fxq "$NEW_ENTRY" "$PG_HBA_CONF_PATH"; then
    echo "Replication entry already exists in pg_hba.conf."
else
    echo "Adding replication entry to pg_hba.conf..."
    echo "$NEW_ENTRY" >> "$PG_HBA_CONF_PATH"
    echo "Replication entry added successfully."
fi

# Reload PostgreSQL configuration to apply changes
psql -U postgres -c "SELECT pg_reload_conf();"
