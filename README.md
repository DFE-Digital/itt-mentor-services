# ITT mentor services

[![View performance data on Skylight](https://badges.skylight.io/status/6v9PqzmAQIZi.svg?token=Qy2pZYtgRhgzOEiw8KVg4W9NcBRP2spyrwET1FsqaAE)](https://www.skylight.io/app/applications/6v9PqzmAQIZi)

This application has one service:

- Claim funding for mentor training: A service for placement partners to claim funding for their general mentors’ training.

## Documentation

Start with the [claims documentation index](docs/claims/README.md) for developer onboarding, architecture, Mermaid diagrams, APIs and operational guides.

The [handover document](handover-document.md) summarises run-state ownership. The [documentation audit](docs/claims/documentation-audit.md) records evidence and outstanding team-input gaps.

## Live Environments

### Claim funding for mentor training

| Name       | URL                                                                           | Purpose                                                                | AKS Namespace  |
| ---------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------- | -------------- |
| Production | [www](https://claim-funding-for-itt-mentor-training.service.gov.uk)             | Public site                                                            | bat-production |
| Sandbox    | [sandbox](https://sandbox.claim-funding-for-itt-mentor-training.service.gov.uk) | Demo environment for end-users                                         | bat-production |
| Staging    | [staging](https://staging.claim-funding-for-itt-mentor-training.service.gov.uk) | For internal use by DfE for testing - Production-like environment      | bat-staging    |
| QA         | [qa](https://qa.claim-funding-for-itt-mentor-training.service.gov.uk)           | For internal use by DfE for testing - Automatically deployed from main | bat-qa         |

The canonical production [sign-in](https://claim-funding-for-itt-mentor-training.service.gov.uk/sign-in) was confirmed at handover. The former `education.gov.uk` address is not a supported alias. See the [deployment guide](docs/claims/deployment.md) for the remaining legacy-domain configuration discrepancy.

## Setup

### Prerequisites

This project depends on:

- [Ruby](https://www.ruby-lang.org/)
- [Ruby on Rails](https://rubyonrails.org/)
- [NodeJS](https://nodejs.org/)
- [Yarn](https://yarnpkg.com/) (managed with Corepack)
- [Postgres](https://www.postgresql.org/)

### asdf

Most dependencies are defined in the `.tool-versions` file and can be installed using [asdf](https://asdf-vm.com/) (or a compatible alternative like [mise](https://mise.jdx.dev/)).
Yarn is managed separately by Corepack.

To install them with asdf, run:

```sh
# The first time
brew install asdf # Mac-specific
asdf plugin add nodejs
asdf plugin add ruby
asdf plugin add caddy
asdf plugin add azure-cli
asdf plugin add jq
asdf plugin add kubectl
asdf plugin add kubelogin
asdf plugin add python
asdf plugin add terraform

# To install (or update, following a change to .tool-versions)
asdf install
```

### Yarn and Corepack

The project pins Yarn 4.18.1 in `package.json` and selects the committed Yarn release through `.yarnrc.yml`. Do not install Yarn with asdf. After installing Node, enable Corepack's Yarn command once:

```sh
corepack enable
```

In this repository, `yarn --version` should report `4.18.1`.

### Homebrew

You'll also need a few packages which asdf either doesn't have plugins for, or it can't reliably install them. For example, for some reason asdf installs `cmake` as an unsigned binary so it won't run on macOS.

Install them using Homebrew:

```sh
brew bundle
```

This will install the packages listed in [Brewfile](Brewfile).

Finally, you will need a running Postgres 17 server. You can install it with Homebrew by running:

```sh
brew install postgresql@17
```

or you may prefer to use [Postgres.app](https://postgresapp.com/), [Docker](https://hub.docker.com/_/postgres), or some other [installation method](https://www.postgresql.org/download/).

The local Docker Compose database also uses PostgreSQL 17. If you have data in an existing PostgreSQL 16 Compose volume, export it before switching versions; PostgreSQL major-version data directories cannot be reused directly. Start PostgreSQL 17 with a fresh volume and restore a dump if you need to keep that data.

### Linting

`bin/lint` runs RuboCop with `--autocorrect-all` and ERB Lint with `--autocorrect`, so it can modify files. Review its diff before keeping any corrections.

For check-only linting that does not enable autocorrection, run:

```bash
bundle exec rubocop
bundle exec erb_lint app
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

Add your test key as `GOVUK_NOTIFY_API_KEY` in the ignored local overrides `.env.development.local` and, when needed, `.env.test.local`. Do not put keys in tracked environment files.

`bin/setup` copies `.env.example` to `.env.development.local` if that local file does not exist. You can create it from the example before setup to configure your local database and test key.

### Running the app

To run the application locally:

1. Run `yarn install --immutable` to install JavaScript dependencies.
2. Check that the environment points to a local development database.
3. Run `bin/setup` to install Ruby dependencies, set up the database and launch the app on <http://claims.localhost:3000>. The repository also retains placements development routes.

See [developer onboarding](docs/claims/development.md) for setup side effects, test commands and current wizard/service interfaces.

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
