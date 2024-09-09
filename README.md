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

**Slave to master:**

```
$> docker exec -u postgres -it postgres-slave bash
$> pg_ctl promote -D /var/lib/postgresql/data
```

**Master to slave:**

```
$> docker exec -u postgres -it postgres-master bash
$> pg_ctl stop -D /var/lib/postgresql/data -m fast

$> docker exec -u postgres -it postgres-master bash
$> rm -rf /var/lib/postgresql/data/*
$> pg_basebackup -h postgres-slave -U postgres -D /var/lib/postgresql/data -Fp -Xs -P -R
$> exec docker-entrypoint.sh postgres
```

**Example:**

```
# Write to master
$> bash write_test_data.sh -> Error
# Read from slave
$> bash read_from_slave.sh -> response 2 rows
```

change master -> slave; slave -> master in bash scripts and repeat the test

```
# Write to slave
$> bash write_test_data.sh -> response 4 rows
# Read from master or slave
$> bash read_from_slave.sh -> response 4 rows
```
