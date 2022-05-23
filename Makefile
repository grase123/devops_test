SHELL=bash
SERVICE_NAME = hello_app
CONTAINER_NAME = myservice:1.0

default: help

.PHONY: help
help:             ## Show this help
	@printf "\nHelp\n------\n\n"
	@grep -E '\s##\s' $(MAKEFILE_LIST)
	@printf "\n\n"

 ## 
 ## ---------------------- project commands (without k8s):
 ## 

 .PHONY: project_up
project_up:       ## start the entire project
	@printf "$@ \n"
	@$(MAKE) docker_network_create       # create network for monitoring
	@$(MAKE) compose_app_up              # start application 
	@$(MAKE) compose_infra_up            # start infrastructure for monitoring
	@printf "\n"


 .PHONY: project_down
project_down:     ## stop the entire project
	@printf "$@ \n"
	@$(MAKE) compose_infra_down            # stop infrastructure for monitoring
	@$(MAKE) compose_app_down              # stop application 
	@$(MAKE) docker_network_delete         # create network for monitoring
	@printf "\n"


.PHONY: project_ps
project_ps:       ## list all running containers
	@printf "$@ \n"
	@$(MAKE) compose_infra_ps 
	@$(MAKE) compose_app_ps  
	@printf "\n"




 ## 
 ## ---------------------- application commands:
 ## 

.PHONY: app_test
app_test:                 ## build webapp and run app localy without container
	@rm -rf ./app
	@echo "Build webapp: ./app/$(SERVICE_NAME)" && \
	pushd src > /dev/null && \
	go get github.com/prometheus/client_golang/prometheus/promhttp && \
	go mod download && \
	go build -o ../app/$(SERVICE_NAME) && \
	popd > /dev/null 

	@echo "Start webapp: ./app/$(SERVICE_NAME)" && \
	./app/$(SERVICE_NAME)

 ##  
 ## ---------------------- docker commands:
 ## 

.PHONY: docker_app_build
docker_app_build:         ## build and start webapp in docker container
	@printf "\n>> build docker image: '$(CONTAINER_NAME)' with app: '$(SERVICE_NAME)'\n\n"
	@docker --version
	@docker image build \
		--build-arg \
			SERVICE_NAME=$(SERVICE_NAME) \
		-f ./Dockerfiles/Dockerfile \
		-t $(CONTAINER_NAME) ./src

	@printf "\n>> start webapp contaner based on image: '$(CONTAINER_NAME)' on port 8080\n\n"
	@docker run --rm -p 8080:8080 -p 9000:9000 $(CONTAINER_NAME)


.PHONY: docker_app_up
docker_app_up:            ## start contaner based on image 
	@printf "\n>> start contaner based on image: '$(CONTAINER_NAME)' on port 8080\n\n"
	@docker run --rm -p 8080:8080 -p 9000:9000 $(CONTAINER_NAME)


.PHONY: docker_network_create
docker_network_create:    ## create network for monitoring 
	@printf "\n>> create external network 'monitor_net': "
	@docker network create monitor_net >/dev/null 2>/dev/null \
		&& printf "created\n" \
		|| printf "skipped, 'monitor_net' is already exist\n" 
	@printf "\n"


.PHONY: docker_network_delete
docker_network_delete:    ## delete network for monitoring 
	@printf "\n>> delete external network 'monitor_net': "
	@docker network rm monitor_net >/dev/null 2>/dev/null \
		&& printf "deleted\n" \
		|| printf "skipped, 'monitor_net' is still in use\n" 
	@printf "\n"


 ##  
 ## ---------------------- docker-compose commands:
 ## 

.PHONY: compose_app_up
compose_app_up:           ## start application containers
	@printf "\n>> start application contaners, application is based on image: '$(CONTAINER_NAME)' on port 8080\n\n"
	@pushd DockerCompose > /dev/null && \
	docker-compose up --build -d && \
	popd > /dev/null
	@printf "\n"


.PHONY: compose_app_down
compose_app_down:         ## stop application containers 
	@printf "\n>> stop application contaners \n\n"
	@pushd DockerCompose > /dev/null && \
	docker-compose down && \
	popd > /dev/null
	@printf "\n"


.PHONY: compose_app_ps
compose_app_ps:           ## list application containers
	@printf "\n>> list application containers \n\n"
	@pushd DockerCompose > /dev/null && \
	docker-compose ps && \
	popd > /dev/null
	@printf "\n"


.PHONY: compose_infra_up
compose_infra_up:         ## start infrastructure for monitoring 
	@printf "\n>> start infrastructure for monitoring"
	@pushd Monitoring > /dev/null && \
	docker-compose up --build -d && \
	popd > /dev/null
	@printf "\n"


.PHONY: compose_infra_down
compose_infra_down:       ## stop infrastructure 
	@printf "\n>> stop infrastructure contaners \n\n"
	@pushd Monitoring > /dev/null && \
	docker-compose down && \
	popd > /dev/null
	@printf "\n"


.PHONY: compose_infra_ps
compose_infra_ps:         ## list infrastructure containers
	@printf "\n>> list infrastructure containers \n\n"
	@pushd Monitoring > /dev/null && \
	docker-compose ps && \
	popd > /dev/null
	@printf "\n"




