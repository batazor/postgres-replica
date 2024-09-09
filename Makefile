up:
	@docker-compose up -d

down:
	@docker-compose down --remove-orphans
	@rm -rf ./data

# Promote the slave to master
promote-slave-to-master:
	@echo "Promoting slave to master..."
	@docker exec -u postgres postgres-slave pg_ctl promote -D /var/lib/postgresql/data
	@echo "Slave promoted to master!"

# Stop the current master
stop-master:
	@docker start postgres-master
	@echo "Stopping the old master..."
	@docker exec -u postgres postgres-master pg_ctl stop -D /var/lib/postgresql/data -m fast
	@echo "Old master stopped."
	@docker start postgres-master

# Reconfigure the old master as a slave
reconfigure-master-as-slave:
	@echo "Reconfiguring the old master as the new slave..."
	# Take a new base backup from the new master (previous slave)
	@docker exec -u postgres postgres-master bash -c "rm -rf /var/lib/postgresql/data/* && pg_basebackup -h postgres-slave -U postgres -D /var/lib/postgresql/data -Fp -Xs -P -R"

	@echo "Old master reconfigured as slave!"

# Promote the current master back to the master role
promote-master-to-master:
	@echo "Promoting the original master back to master..."
	@docker exec -u postgres postgres-master pg_ctl promote -D /var/lib/postgresql/data
	@echo "Original master promoted to master!"

# Stop the current slave
stop-slave:
	@docker start postgres-slave
	@echo "Stopping the current slave..."
	@docker exec -u postgres postgres-slave pg_ctl stop -D /var/lib/postgresql/data -m fast
	@echo "Current slave stopped."
	@docker start postgres-slave

# Reconfigure the current master as the slave
reconfigure-slave-as-slave:
	@echo "Reconfiguring the current master as the slave..."
	@docker exec postgres-slave bash -c "rm -rf /var/lib/postgresql/data/* && pg_basebackup -h postgres-master -U postgres -D /var/lib/postgresql/data -Fp -Xs -P -R"
	@echo "Current master reconfigured as slave!"
	@docker start postgres-slave

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
