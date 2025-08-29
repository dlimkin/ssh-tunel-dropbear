
NAME := ssh-tunnel-dropbear
VERSION := 1.4.2

DOCKER_USERNAME = dlimkin

version:
	sed -i 's/#version#/$(VERSION)/g' motd.txt

version-reset:
	sed -i 's/$(VERSION)/#version#/g' motd.txt

build:
	docker build --no-cache -t $(NAME):$(VERSION) -f Dockerfile .

push:
	docker tag $(NAME):$(VERSION) $(DOCKER_USERNAME)/$(NAME):$(VERSION)
	docker tag $(NAME):$(VERSION) $(DOCKER_USERNAME)/$(NAME):latest
	@docker push -a $(DOCKER_USERNAME)/$(NAME)

deploy: version build push version-reset