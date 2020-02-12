
all:
	cd docker && docker-compose down -v && \
	docker-compose up --build --force-recreate -V --remove-orphans --abort-on-container-exit \
