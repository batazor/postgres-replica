up:
	@docker-compose up -d

down:
	@docker-compose down --remove-orphans
	@rm -rf ./data
