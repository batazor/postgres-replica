### Postgres replica

#### Getting start

```
# Run postgres master and slave
$> make up

# Write test data
$> bash write_test_data.sh

# Read test data
$> bash read_from_slave.sh

# Set slave as master
$> make promote-slave-to-master
$> make stop-master
$> reconfigure-master-as-slave

# Write test data
$> bash write_test_data.sh #> failed because master is read-only

# Read test data
$> bash read_from_slave.sh #> success
```