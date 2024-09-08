#!/bin/bash

# Variables
SLAVE_CONTAINER="postgres-slave"
POSTGRES_USER="postgres"
POSTGRES_DB="mydb"
POSTGRES_PASSWORD="password"

# Read data from slave
echo "Reading data from PostgreSQL slave..."

docker exec -e PGPASSWORD=$POSTGRES_PASSWORD $SLAVE_CONTAINER psql -U $POSTGRES_USER -d $POSTGRES_DB -c "
SELECT * FROM test_data;
"

if [ $? -eq 0 ]; then
    echo "Data read successfully from the slave!"
else
    echo "Failed to read data from the slave."
fi
