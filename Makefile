BRANCH = master
NETWORK := calibnet 
SOURCE_DIR = "$(HOME)/lotus"


.PHONY: build
build:
	docker image build --network host --build-arg NETWORK=$(NETWORK) --build-arg BRANCH=$(BRANCH) -t glif/lotus:$(BRANCH) .

.PHONY: rebuild
rebuild:
	docker image build --no-cache  --network host --build-arg NETWORK=$(NETWORK) --build-arg BRANCH=$(BRANCH) -t glif/lotus:$(BRANCH) .

.PHONY: push
push:
	docker push glif/lotus:$(BRANCH)

build_lotus:
	./build/build_lotus.sh

rebuild_lotus:
	./build/build_lotus.sh rebuild

git-push:
	git commit -a -m "$(BRANCH)" && git push && git tag $(BRANCH) && git push --tags

.PHONY: run
run:
	docker run -d --name lotus \
	-p 1234:1234 -p 1235:1235 \
	-e INFRA_LOTUS_DAEMON="true" \
	-e INFRA_LOTUS_HOME="/home/lotus_user" \
	-e INFRA_IMPORT_SNAPSHOT="true" \
	-e SNAPSHOTURL="https://snapshots.mainnet.filops.net/minimal/latest.zst" \
	-e INFRA_SYNC="true" \
	--network host \
	--restart always \
	--mount type=bind,source=$(SOURCE_DIR),target=/home/lotus_user \
	glif/lotus:$(BRANCH)

.PHONY: run-calibnet
run-calibnet:
	docker run -d --name lotus \
	-p 1234:1234 -p 1235:1235 \
	-e INFRA_LOTUS_DAEMON="true" \
	-e INFRA_LOTUS_HOME="/home/lotus_user" \
	-e INFRA_IMPORT_SNAPSHOT="true" \
	-e SNAPSHOTURL="https://snapshots.calibrationnet.filops.net/minimal/latest.zst" \
	-e INFRA_SYNC="true" \
	--network host \
	--restart always \
	--mount type=bind,source=$(SOURCE_DIR),target=/home/lotus_user \
	glif/lotus:$(BRANCH)


run-bash:
	docker container run -p 1235:1235 -p 1234:1234 -it --entrypoint=/bin/bash --name lotus --rm glif/lotus:$(BRANCH)

bash:
	docker exec -it lotus /bin/bash

sync-status:
	docker exec -it lotus lotus sync status

log:
	docker logs lotus -f

rm:
	docker stop lotus
	docker rm lotus
