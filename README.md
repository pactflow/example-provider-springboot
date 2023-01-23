# Example Java Spring Boot Provider

![Build](https://github.com/pactflow/example-provider-springboot/workflows/Build/badge.svg)

[![Can I deploy Status](https://test.pactflow.io/pacticipants/pactflow-example-provider-springboot/branches/master/latest-version/can-i-deploy/to-environment/production/badge.svg)](https://test.pactflow.io/overview/provider/pactflow-example-provider-springboot/consumer/pactflow-example-consumer-java-junit)

[![Pact Status](https://test.pactflow.io/pacts/provider/pactflow-example-provider-springboot/consumer/pactflow-example-consumer-java-junit/latest/badge.svg)](https://test.pactflow.io/pacts/provider/pactflow-example-provider-springboot/consumer/pactflow-example-consumer-java-junit/latest) (latest pact)

[![Pact Status](https://test.pactflow.io/pacts/provider/pactflow-example-provider-springboot/consumer/pactflow-example-consumer-java-junit/latest/prod/badge.svg)](https://test.pactflow.io/pacts/provider/pactflow-example-provider-springboot/consumer/pactflow-example-consumer-java-junit/latest/prod) (prod/prod pact)


This is an example of a Java Spring Boot provider that uses Pact, [PactFlow](https://pactflow.io) and GitHub Actions to ensure that it is compatible with the expectations its consumers have of it.

The project uses a Makefile to simulate a very simple build pipeline with two stages - test and deploy.

It is using a public tenant on PactFlow, which you can access [here](https://test.pactflow.io) using the credentials `dXfltyFMgNOFZAxr8io9wJ37iUpY42M`/`O5AIZWxelWbLvqMd8PkAVycBJh2Psyg1`.

## Project Phases

The project uses a Makefile to simulate a very simple build pipeline with two stages - test and deploy.

- Test
  - Run tests (including the pact tests that generate the contract)
  - Publish pacts, tagging the consumer version with the name of the current branch
  - Check if we are safe to deploy to prod (ie. has the pact content been successfully verified)
- Deploy (only from master)
  - Deploy app (just pretend for the purposes of this example!)
  - Tag the deployed consumer version as 'prod'

## Dependencies

- Docker
- A [PactFlow](https://pactflow.io) account
- A [read/write API Token](https://docs.pactflow.io/#configuring-your-api-token) from your PactFlow account
- Java 8+ installed

## Usage

See the [PactFlow CI/CD Workshop](https://github.com/pactflow/ci-cd-workshop).

The below commands are designed for a Linux/OSX environment, please translate for use on Windows/PowerShell as necessary:

Please ensure the following environment variables have been exported in the process that you run the tests (generally a terminal):

```
export PACT_BROKER_TOKEN=<your pactflow read/write token here>
export PACT_BROKER_BASE_URL=https://<your pactflow subdomain>.pactflow.io
export PACT_BROKER_HOST=<your pactflow subdomain>.pactflow.io
```

You can run the tests locally with:

```
make test
```

### Simulating CI

Usually, you would integrate this into a real CI system (such as Buildkite/Jenkins/CircleCI etc., or GitHub Actions as this repository is built against).

You can simulate a CI process with the following command:

```
make fake_ci
```
