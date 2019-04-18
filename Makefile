TAG = $(shell git describe --tags --always)
PREFIX = $(shell git config --get remote.origin.url | tr ':.' '/'  | rev | cut -d '/' -f 3 | rev)
REPO_NAME = $(shell git config --get remote.origin.url | tr ':.' '/'  | rev | cut -d '/' -f 2 | rev)

all: image

container: image

image:
	docker build -t $(PREFIX)/$(REPO_NAME) . # Build new image and automatically tag it as latest
	docker tag $(PREFIX)/$(REPO_NAME) $(PREFIX)/$(REPO_NAME):$(TAG)  # Add the version tag to the latest image

push: image
	echo "$(DOCKER_PASSWORD)" | docker login --username "$(DOCKER_USERNAME)" --password-stdin
	docker push $(PREFIX)/$(REPO_NAME) # Push image tagged as latest to repository
	docker push $(PREFIX)/$(REPO_NAME):$(TAG) # Push version tagged image to repository (since this image is already pushed it will simply create or update version tag)

clean:
	docker rmi $(PREFIX)/$(REPO_NAME)
	docker rmi $(PREFIX)/$(REPO_NAME):$(TAG)
	docker rmi $(PREFIX)/$(REPO_NAME):test

test: image
	docker tag $(PREFIX)/$(REPO_NAME) $(PREFIX)/$(REPO_NAME):test  # Add a tag for the current image to be tested
