#!/bin/bash

# Variables
MASTER_CONTAINER="postgres-master"
POSTGRES_USER="postgres"
POSTGRES_DB="mydb"
POSTGRES_PASSWORD="password"

# Insert test data
echo "Inserting test data into PostgreSQL master..."

docker exec -e PGPASSWORD=$POSTGRES_PASSWORD $MASTER_CONTAINER psql -U $POSTGRES_USER -d $POSTGRES_DB -c "
CREATE TABLE IF NOT EXISTS test_data (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);
INSERT INTO test_data (name, email) VALUES
    ('John Doe', 'john.doe@example.com'),
    ('Jane Doe', 'jane.doe@example.com')
    ON CONFLICT DO NOTHING;
SELECT * FROM test_data;
"

if [ $? -eq 0 ]; then
    echo "Test data inserted successfully!"
else
    echo "Failed to insert test data."
fi
