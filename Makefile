include make_env

.PHONY: login build rebuild push pull shell jupyter run start connect stop rm release

build: Dockerfile
	DOCKER_BUILDKIT=1 docker build $(BUILD_ARGS) $(BUILD_SSH) --progress=plain -t $(IMG_ID_LOCAL) -f Dockerfile . $(TAIL)

rebuild: Dockerfile
	DOCKER_BUILDKIT=1 docker build --no-cache $(BUILD_ARGS) $(BUILD_SSH) -t $(IMG_ID_LOCAL) -f Dockerfile . $(TAIL)

push: tag-remote
	docker push $(IMG_ID_REMOTE) $(TAIL)

pull: login
	docker pull $(IMG_ID_REMOTE) $(TAIL)
	docker tag $(IMG_ID_REMOTE) $(IMG_ID_LOCAL) $(TAIL)

tag-local:
	docker tag $(IMG_ID_REMOTE) $(IMG_ID_LOCAL) $(TAIL)

tag-remote:
	docker tag $(IMG_ID_LOCAL) $(IMG_ID_REMOTE) $(TAIL)

shell:
	docker run --name $(CONTAINER_NAME)-$(VERSION) -it $(PORTS) $(VOLUMES) $(RUN_ARGS) $(IMG_ID_LOCAL) /bin/bash $(TAIL)

remove:
	docker rm $(CONTAINER_NAME)-$(VERSION)

volume: 
	docker volume create --driver local --opt type=nfs --opt o=addr=$(NAS_IP_ADDR),rw --opt device=:$(NAS_VOLUME_PATH) seq_data 

start:
	docker start $(CONTAINER_NAME)-$(VERSION)

stop:
	docker stop $(CONTAINER_NAME)-$(VERSION)

connect:
	docker exec -it $(CONTAINER_NAME)-$(VERSION) /bin/bash $(TAIL)

release: build
	make push -e VERSION=$(VERSION) $(TAIL)

default: build

