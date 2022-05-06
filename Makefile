SHELL=/bin/bash
CDK_DIR=infrastructure/
COMPOSE_RUN = docker-compose run --rm cdk-base
COMPOSE_UP = docker-compose up
ACT = cmdlab-sandpit2
PROFILE = --profile ${ACT}

all: pre-reqs

pre-reqs: _prep-cache container-build npm-install container-info bootstrap

_prep-cache:
	mkdir -p infrastructure/cdk.out/

container-build: pre-reqs
	docker-compose build

container-info:
	${COMPOSE_RUN} make _container-info

_container-info:
	chmod 755 ./containerInfo.sh
	./containerInfo.sh

clear-cache:
	${COMPOSE_RUN} rm -rf ${CDK_DIR}cdk.out && rm -rf ${CDK_DIR}node_modules

npm-install: _prep-cache
	${COMPOSE_RUN} make _npm-install

_npm-install:
	cd ${CDK_DIR} && npm install

npm-update: _prep-cache
	${COMPOSE_RUN} make _npm-update

_npm-update:
	cd ${CDK_DIR} && npm update

cli: _prep-cache
	docker-compose run cdk-base /bin/bash

ls: _prep-cache
	${COMPOSE_RUN} make _ls

_ls:
	cd ${CDK_DIR} && cdk ls --context act=${ACT} ${PROFILE}

synth: _prep-cache
	${COMPOSE_RUN} make _synth

_synth:
	cd ${CDK_DIR} && cdk synth --no-staging --context act=${ACT} ${PROFILE}

bootstrap: _prep-cache
	${COMPOSE_RUN} make _bootstrap

_bootstrap:
	cd ${CDK_DIR} && cdk bootstrap --context act=${ACT} ${PROFILE}

deploy: _prep-cache
	${COMPOSE_RUN} make _deploy

_deploy: 
	cd ${CDK_DIR} && cdk deploy --all --require-approval never --context act=${ACT} ${PROFILE}

destroy:
	${COMPOSE_RUN} make _destroy

_destroy:
	cd ${CDK_DIR} && cdk destroy --force --context act=${ACT} ${PROFILE}

diff: _prep-cache
	${COMPOSE_RUN} make _diff

_diff: _prep-cache
	cd ${CDK_DIR} && cdk diff --context act=${ACT} ${PROFILE}