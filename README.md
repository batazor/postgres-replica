### Postgres replica

#### Getting start

**Run master:**

```
# Run postgres master and slave
$> make up

# Enter master container
$> docker exec -u postgres -it postgres-master bash

# Run postgres on master
$> exec docker-entrypoint.sh postgres
```

**Run slave:**

```
# Enter slave container
$> docker exec -u postgres -it postgres-slave bash

# Made replication
$> pg_basebackup -h postgres-master -U postgres -D /var/lib/postgresql/data -Fp -Xs -P -R

# Run postgres on slave
$> exec docker-entrypoint.sh postgres
```

**Example:**

```
# Write to master
$> bash write_test_data.sh
# Read from slave
$> bash read_from_slave.sh
```