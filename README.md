# ITT mentor services

[![View performance data on Skylight](https://badges.skylight.io/status/6v9PqzmAQIZi.svg?token=Qy2pZYtgRhgzOEiw8KVg4W9NcBRP2spyrwET1FsqaAE)](https://www.skylight.io/app/applications/6v9PqzmAQIZi)

This application has one service:

- Claim funding for mentor training: A service for placement partners to claim funding for their general mentors’ training.

## Live Environments

### Claim funding for mentor training

| Name       | URL                                                                           | Purpose                                                                | AKS Namespace  |
| ---------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------- | -------------- |
| Production | [www](https://claim-funding-for-mentor-training.education.gov.uk)             | Public site                                                            | bat-production |
| Sandbox    | [sandbox](https://sandbox.claim-funding-for-mentor-training.education.gov.uk) | Demo environment for end-users                                         | bat-production |
| Staging    | [staging](https://staging.claim-funding-for-mentor-training.education.gov.uk) | For internal use by DfE for testing - Production-like environment      | bat-staging    |
| QA         | [qa](https://qa.claim-funding-for-mentor-training.education.gov.uk)           | For internal use by DfE for testing - Automatically deployed from main | bat-qa         |

## Setup

### Prerequisites

This project depends on:

- [Ruby](https://www.ruby-lang.org/)
- [Ruby on Rails](https://rubyonrails.org/)
- [NodeJS](https://nodejs.org/)
- [Yarn](https://yarnpkg.com/)
- [Postgres](https://www.postgresql.org/)

### asdf

Most dependencies are defined in the `.tool-versions` file and can be installed using [asdf](https://asdf-vm.com/) (or a compatible alternative like [mise](https://mise.jdx.dev/)).

To install them with asdf, run:

```sh
# The first time
brew install asdf # Mac-specific
asdf plugin add nodejs
asdf plugin add ruby
asdf plugin add yarn
asdf plugin add azure-cli
asdf plugin add jq
asdf plugin add kubectl
asdf plugin add kubelogin
asdf plugin add python
asdf plugin add terraform

# To install (or update, following a change to .tool-versions)
asdf install
```

### Homebrew

You'll also need a few packages which asdf either doesn't have plugins for, or it can't reliably install them. For example, for some reason asdf installs `cmake` as an unsigned binary so it won't run on macOS.

Install them using Homebrew:

```sh
brew bundle
```

This will install the packages listed in [Brewfile](Brewfile).

Finally, you will need a running Postgres 16 server. You can install it with Homebrew by running:

```sh
brew install postgresql@16
```

or you may prefer to use [Postgres.app](https://postgresapp.com/), [Docker](https://hub.docker.com/_/postgres), or some other [installation method](https://www.postgresql.org/download/).

### Linting

To run the linters:

```bash
bin/lint
```

## How the application works

We keep track of architecture decisions in [Architecture Decision Records
(ADRs)](/adr/).

We use `rladr` to generate the boilerplate for new records:

```bash
bin/bundle exec rladr new title
```

### GOV.UK Notify

The application requires you to add your API key for `GOVUK_NOTIFY_API_KEY`, to gain access to this service ask your
team lead to invite you to GOV.UK Notify.

Once you have access, navigate to [API integration](https://www.notifications.service.gov.uk/services/022acc23-c40a-4077-bbd6-fc98b2155534/api) -> [API Keys](https://www.notifications.service.gov.uk/services/022acc23-c40a-4077-bbd6-fc98b2155534/api/keys) -> [Create an API Key](https://www.notifications.service.gov.uk/services/022acc23-c40a-4077-bbd6-fc98b2155534/api/keys/create)

Name your key in a sensible and identifiable way, e.g. `[YOUR-NAME] Local Test Key` and set the type of key to **Test**.

Create your key and then add it to `.env.test` and `.env.development` where it says `GOVUK_NOTIFY_API_KEY=`.

You will also need to create a `.env` file in the same directory as `.env.test` and `.env.development`. The contents of the new `.env` file should be a copy of `.env.example`.

### Running the app

To run the application locally:

1. Run `yarn` to install dependencies for the web app to run
2. Run `bin/setup` to setup the database
3. Run `bin/dev` to launch the app on <http://placements.localhost:3000> or <http://claims.localhost:3000>

### Seed Data

To run the seed data to generate the following:

- Persona
  - Anne Wilson - School
  - Patricia Adebayo - University
  - Mary Lawson - Multi-org
  - Colin Chapman - Support

```bash
  bin/bundle exec rails db:seed
```
