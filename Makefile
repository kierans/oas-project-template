DOCKER_RUN=docker run --rm
DOCKER_CLI=$(DOCKER_RUN) $(DOCKER_VOLUMES) $(DOCKER_IMAGE)
DOCKER_IMAGE=oas-builder
DOCKER_RENDER_ERROR=$(DOCKER_RENDER_TEMPLATE) $(ERROR_TEMPLATE)
DOCKER_RENDER_TEMPLATE=$(DOCKER_CLI) /usr/local/bin/render-template.sh
DOCKER_SERVE=$(DOCKER_RUN) -p 8080:8080 $(DOCKER_VOLUMES) $(DOCKER_IMAGE)
DOCKER_VOLUMES=-v $(CURDIR):/oas

DIST_SPEC=/oas/dist/oas-spec.json
SRC_SPEC=/oas/src/oas-spec.yml

ERROR_TEMPLATE=/oas/src/responses/generic-error.yml.hbs

assemble: generate
	@$(DOCKER_CLI) npx redocly bundle $(SRC_SPEC) --output $(DIST_SPEC) --lint --ext=json

clean:
	rm -rf dist
	docker images | grep "^<none>" | awk '{print $$3}' | xargs -n1 docker rmi

dist: assemble
	@$(DOCKER_CLI) npx redoc-cli build $(DIST_SPEC) --output /oas/dist/doc/index.html

docker:
	docker build -t $(DOCKER_IMAGE) .

generate: src/responses/bad-request.yml \
          src/responses/not-found.yml \
          src/responses/method-not-allowed.yml \

serve:
	$(DOCKER_SERVE) npx redocly preview-docs $(DIST_SPEC) --host=0.0.0.0

src/responses/bad-request.yml: src/responses/generic-error.yml.hbs
	$(DOCKER_RENDER_ERROR) '{ "description": "Invalid ID supplied" }' > src/responses/bad-request.yml

src/responses/not-found.yml: src/responses/generic-error.yml.hbs
	$(DOCKER_RENDER_ERROR) '{ "description": "Not found" }' > src/responses/not-found.yml

src/responses/method-not-allowed.yml: src/responses/generic-error.yml.hbs
	$(DOCKER_RENDER_ERROR) '{ "description": "Validation error" }' > src/responses/method-not-allowed.yml

.PHONY: assemble clean dist docker
