# ITT mentor services

This application has two main services:

- A service where schools or training providers can claim funding for internal teacher training.
- TODO: Add description for the other service

## Live Environments

| Name       | URL | Purpose | AKS Namespace |
| ---------- | --- | ------- | ------------- |
| Production | *pending* | Public site | bat-production |
| Sandbox    | *pending* | Demo environment for end-users | bat-production |
| Staging    | *pending* | For internal use by DfE for testing - Production-like environment | bat-staging |
| QA         | [Track & Pay](https://track-and-pay-qa.test.teacherservices.cloud) / [School Placements](https://manage-school-placements-qa.test.teacherservices.cloud) | For internal use by DfE for testing - Automatically deployed from main | bat-qa |

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

You'll also need a couple of packages which asdf can't reliably install. (For some reason asdf installs them as unsigned binaries, so they won't run on macOS.)

Install them using Homebrew:

```sh
brew install cmake pkg-config
```

Finally, you will need a running Postgres 16 server. You can install it with Homebrew by running:

```sh
brew install postgresql@16
```

### Linting

To run the linters:

```bash
bin/lint
```

### Intellisense

[solargraph](https://github.com/castwide/solargraph) is bundled as part of the
development dependencies. You need to [set it up for your
editor](https://github.com/castwide/solargraph#using-solargraph), and then run
this command to index your local bundle (re-run if/when we install new
dependencies and you want completion):

```sh
bin/bundle exec yard gems
```

You'll also need to configure your editor's `solargraph` plugin to
`useBundler`:

```diff
+  "solargraph.useBundler": true,
```

## How the application works

We keep track of architecture decisions in [Architecture Decision Records
(ADRs)](/adr/).

We use `rladr` to generate the boilerplate for new records:

```bash
bin/bundle exec rladr new title
```

### Running the app

To run the application locally:

1. Run `yarn` to install dependencies for the web app to run
2. Run `bin/setup` to setup the database
3. Run `bin/dev` to launch the app on <http://localhost:3000>

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
