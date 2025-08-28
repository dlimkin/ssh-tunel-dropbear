
NAME := ssh-tunnel-dropbear
VERSION := 1.0.0

DOCKER_USERNAME = dlimkin

build:
	docker build --no-cache -t $(NAME):$(VERSION) -f Dockerfile .

push:
	docker tag $(NAME):$(VERSION) $(DOCKER_USERNAME)/$(NAME):$(VERSION)
	docker tag $(NAME):$(VERSION) $(DOCKER_USERNAME)/$(NAME):latest
	@docker push -a $(DOCKER_USERNAME)/$(NAME)


deploy: build push