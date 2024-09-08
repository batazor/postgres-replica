# Define container names
SLAVE_CONTAINER=postgres-slave
MASTER_CONTAINER=postgres-master

# Default data directory in the containers
DATA_DIR=/var/lib/postgresql/data

up:
	@docker-compose up -d

down:
	@docker-compose down --remove-orphans
	@rm -rf ./data

# Promote the slave to master
promote-slave-to-master:
	@echo "Promoting slave to master..."
	@docker exec -u postgres $(SLAVE_CONTAINER) pg_ctl promote -D $(DATA_DIR)
	@echo "Slave promoted to master!"

# Stop the current master
stop-master:
	@docker start $(MASTER_CONTAINER)
	@echo "Stopping the old master..."
	@docker exec -u postgres $(MASTER_CONTAINER) pg_ctl stop -D $(DATA_DIR) -m fast
	@echo "Old master stopped."
	@docker start $(MASTER_CONTAINER)

# Reconfigure the old master as a slave
reconfigure-master-as-slave:
	@echo "Reconfiguring the old master as the new slave..."
	# Take a new base backup from the new master (previous slave)
	@docker exec -u postgres $(MASTER_CONTAINER) bash -c "rm -rf $(DATA_DIR)/* && pg_basebackup -h postgres-slave -U postgres -D /var/lib/postgresql/data -Fp -Xs -P -R"

	@echo "Old master reconfigured as slave!"

# Promote the current master back to the master role
promote-master-to-master:
	@echo "Promoting the original master back to master..."
	@docker exec -u postgres $(MASTER_CONTAINER) pg_ctl promote -D $(DATA_DIR)
	@echo "Original master promoted to master!"

# Reconfigure the current master as the slave
reconfigure-slave-as-slave:
	@echo "Reconfiguring the current master as the slave..."
	@docker exec $(SLAVE_CONTAINER) bash -c "rm -rf $(DATA_DIR)/*"
	@docker exec $(SLAVE_CONTAINER) bash -c "pg_basebackup -h $(MASTER_CONTAINER) -U postgres -D $(DATA_DIR) -Fp -Xs -P -R"
	@docker exec $(SLAVE_CONTAINER) pg_ctl start -D $(DATA_DIR)
	@echo "Current master reconfigured as slave!"

# Switch roles between master and slave
switch-roles:
	@$(MAKE) promote-slave-to-master
	@$(MAKE) stop-master
	@$(MAKE) reconfigure-master-as-slave

# Restore the original roles (optional)
restore-roles:
	@$(MAKE) promote-master-to-master
	@$(MAKE) stop-slave
	@$(MAKE) reconfigure-slave-as-slave
