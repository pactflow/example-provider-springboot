PACTICIPANT := "pactflow-example-provider-springboot"
GITHUB_REPO := "pactflow/example-provider-springboot"

WEBHOOK_UUID := "9GS-Z8nSAbUzvJW4xmhdsg"
CONTRACT_REQUIRING_VERIFICATION_PUBLISHED_WEBHOOK_UUID := "c76b601e-d66a-4eb1-88a4-6ebc50c0df8b"
PACT_CLI="docker run --rm -v ${PWD}:${PWD} -e PACT_BROKER_BASE_URL -e PACT_BROKER_TOKEN pactfoundation/pact-cli"

# Only deploy from master
ifeq ($(GIT_BRANCH),master)
	DEPLOY_TARGET=deploy
else
	DEPLOY_TARGET=no_deploy
endif

all: test

## ====================
## CI tasks
## ====================

ci: test $(DEPLOY_TARGET)

# Run the ci target from a developer machine with the environment variables
# set as if it was on GitHub Actions
# Use this for quick feedback when playing around with your workflows.
fake_ci: .env
	CI=true \
	GIT_COMMIT=`git rev-parse --short HEAD`+`date +%s` \
	GIT_BRANCH=`git rev-parse --abbrev-ref HEAD` \
	PACT_BROKER_PUBLISH_VERIFICATION_RESULTS=true \
	make ci

ci_webhook: .env
	./gradlew clean test -i

fake_ci_webhook:
	CI=true \
	GIT_COMMIT=`git rev-parse --short HEAD`+`date +%s` \
	GIT_BRANCH=`git rev-parse --abbrev-ref HEAD` \
	PACT_BROKER_PUBLISH_VERIFICATION_RESULTS=true \
	make ci_webhook

## =====================
## Build/test tasks
## =====================

test: .env
	./gradlew clean test -i

## =====================
## Deploy tasks
## =====================

deploy: can_i_deploy deploy_app record_deployment

no_deploy:
	@echo "Not deploying as not on master branch"

can_i_deploy: .env
	@"${PACT_CLI}" broker can-i-deploy --pacticipant ${PACTICIPANT} --version ${GIT_COMMIT} --to-environment production

deploy_app:
	@echo "Deploying to prod"

record_deployment:
	@"${PACT_CLI}" broker record_deployment --pacticipant ${PACTICIPANT} --version ${GIT_COMMIT} --environment production

## =====================
## PactFlow set up tasks
## =====================

# export the GITHUB_TOKEN environment variable before running this
create_github_token_secret:
	curl -v -X POST ${PACT_BROKER_BASE_URL}/secrets \
	-H "Authorization: Bearer ${PACT_BROKER_TOKEN}" \
	-H "Content-Type: application/json" \
	-H "Accept: application/hal+json" \
	-d  "{\"name\":\"githubToken\",\"description\":\"Github token\",\"value\":\"${GITHUB_TOKEN}\"}"

# NOTE: the github token secret must be created (either through the UI or using the
# `create_github_token_secret` target) before the webhook is invoked.
create_or_update_contract_requiring_verification_published_webhook:
	"${PACT_CLI}" \
	  broker create-or-update-webhook \
	  "https://api.github.com/repos/${GITHUB_REPO}/dispatches" \
	  --header 'Content-Type: application/json' 'Accept: application/vnd.github.everest-preview+json' 'Authorization: Bearer $${user.githubToken}' \
	  --request POST \
	  --data '{ "event_type": "contract_requiring_verification_published","client_payload": { "pact_url": "$${pactbroker.pactUrl}", "sha": "$${pactbroker.providerVersionNumber}", "branch":"$${pactbroker.providerVersionBranch}" , "message": "Verify changed pact for $${pactbroker.consumerName} version $${pactbroker.consumerVersionNumber} branch $${pactbroker.consumerVersionBranch} by $${pactbroker.providerVersionNumber} ($${pactbroker.providerVersionDescriptions})" } }' \
	  --uuid ${CONTRACT_REQUIRING_VERIFICATION_PUBLISHED_WEBHOOK_UUID} \
	  --provider ${PACTICIPANT} \
	  --contract-requiring-verification-published \
	  --description "contract_requiring_verification_published for ${PACTICIPANT}"

test_contract_requiring_verification_published_webhook:
	@curl -v -X POST ${PACT_BROKER_BASE_URL}/webhooks/${CONTRACT_REQUIRING_VERIFICATION_PUBLISHED_WEBHOOK_UUID}/execute -H "Authorization: Bearer ${PACT_BROKER_TOKEN}"

## ======================
## Misc
## ======================

.env:
	touch .env

schema-test:
	# @./node_modules/.bin/swagger-mock-validator ./oas/swagger.yml ../example-consumer-cypress/pacts/example-cypress-consumer-pactflow-example-provider.json
	./node_modules/.bin/swagger-mock-validator --user dXfltyFMgNOFZAxr8io9wJ37iUpY42M:O5AIZWxelWbLvqMd8PkAVycBJh2Psyg1 --tag master --provider pactflow-example-provider ./oas/swagger.yml https://testdemo.pactflow.io