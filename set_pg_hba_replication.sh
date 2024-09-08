#!/bin/bash

# Variables
PG_CONTAINER="postgres-master"  # Your PostgreSQL container name
PG_HBA_CONF_PATH="/var/lib/postgresql/data/pg_hba.conf"
NEW_ENTRY="host    replication     all             0.0.0.0/0               md5"

# Function to check if the replication line already exists inside the container
check_replication_entry() {
    docker exec -it $PG_CONTAINER bash -c "grep -Fxq \"$NEW_ENTRY\" $PG_HBA_CONF_PATH"
}

# Add the replication entry inside the container if it doesn't exist
add_replication_entry() {
    if check_replication_entry; then
        echo "Replication entry already exists in pg_hba.conf."
    else
        echo "Adding replication entry to pg_hba.conf..."
        docker exec -it $PG_CONTAINER bash -c "echo \"$NEW_ENTRY\" >> $PG_HBA_CONF_PATH"
        echo "Replication entry added successfully."
    fi
}

# Reload PostgreSQL configuration to apply changes inside the container
reload_postgresql_conf() {
    echo "Reloading PostgreSQL configuration..."
    docker exec -it $PG_CONTAINER psql -U postgres -c "SELECT pg_reload_conf();"
    echo "PostgreSQL configuration reloaded."
}

# Run the function to add the replication entry
add_replication_entry

# Reload the PostgreSQL configuration
reload_postgresql_conf
