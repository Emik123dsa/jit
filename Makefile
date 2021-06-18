default: init

init: reset-docker build up wait-instance init-database

init-prod: reset-docker-prod pull-prod up-prod

init-db: deploy-database wait-instance init-database

deploy-database:
	docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d db && docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d adminer

reset-docker:
	-docker-compose -f docker-compose.yml -f docker-compose.override.yml down --rmi=local --volumes --remove-orphans

reset-docker-prod: 
	docker stop back-vsem-edu-nginx && docker stop back-vsem-edu-php-fpm && docker rm back-vsem-edu-nginx && docker rm back-vsem-edu-php-fpm

pull-prod:
	docker pull vsemedu/back-vsem-edu-docker:nginx && docker pull vsemedu/back-vsem-edu-docker:php-fpm

up-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d vsemedu && docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d nginx

push: deploy-nginx deploy-php-fpm

# We are making deploy via CircleCi, therefore it's required to establish image building
# appropriately to the machine folder of building, as an instance, nginx | php-fpm

deploy-nginx:
	docker tag project_nginx:latest vsemedu/back-vsem-edu-docker:nginx && docker push vsemedu/back-vsem-edu-docker:nginx 

deploy-php-fpm:
	docker tag project_vsemedu:latest vsemedu/back-vsem-edu-docker:php-fpm && docker push vsemedu/back-vsem-edu-docker:php-fpm

pull-nginx: 
	docker pull vsemedu/back-vsem-edu-docker:nginx

pull-php-fpm: 
	docker pull vsemedu/back-vsem-edu-docker:php-fpm

build:
	docker-compose -f docker-compose.yml -f docker-compose.override.yml build

up:
	docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

reload:
	docker-compose exec nginx sh -c "service nginx reload"

ssh-db:
	docker-compose exec db /bin/bash

ssh-nginx:
	docker-compose exec nginx /bin/bash 

init-database:
	docker-compose exec db sh -c "mysql -u root -pvsem-edu-root vsem-edu-localhost < /database/admin_default.sql"

wait-instance:
	sleep 60

clean: 
	kubectl delete pods --all 
	kubectl delete service --all
	kubectl delete deployment --all

.PHONY: clean