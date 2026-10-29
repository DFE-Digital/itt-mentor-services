# Developer onboarding

[Claims documentation](README.md)

## Prerequisites and configuration

Use the [README setup](../../README.md#setup), [tool manifest](../../.tool-versions), [Brewfile](../../Brewfile), [Gemfile](../../Gemfile) and [package manifest](../../package.json). PostgreSQL and PROJ are needed. System specs also require the browser configured by the [test support files](../../spec/support/).

Use only a local development database and synthetic data. Never copy production credentials or personal data into local configuration.

1. Install the declared tools and system dependencies.
2. Obtain a GOV.UK Notify **test** key through the approved team access process.
3. Configure ignored local environment overrides. [bin/setup](../../bin/setup) copies `.env.example` to `.env.development.local` only if that local file does not exist. Override test settings in `.env.test.local` if needed. These local patterns are [gitignored](../../.gitignore).
4. Verify the local database settings before running setup or tests.

```sh
yarn install --immutable
bin/setup
```

The setup script installs/checks gems, prepares the database, clears application logs/tempfiles and starts [bin/dev](../../bin/dev). Avoid running it against a shared or valuable database. `bin/setup --skip-server` performs setup without starting the app.

[Procfile.dev](../../Procfile.dev) runs Rails, asset watchers and Caddy. Access claims through the host configured in local environment settings. [Caddyfile](../../Caddyfile) proxies `claims.localhost` to Rails. The [README](../../README.md#running-the-app) also documents direct host/port access.

The expected result is a claims start page with the configured persona sign-in available locally. If setup fails, inspect the failing command before retrying. Do not repeatedly reset the database or replace existing local configuration.

## Seeds and smoke checks

Against a disposable local database:

```sh
bin/bundle exec rails db:seed
```

See [seeds](../../db/seeds.rb) and [seed data description](../../README.md#seed-data). Verify you can select the intended school/support persona, locate a school and inspect a claim window before testing claim creation. Seed content is not a production onboarding process.

## Test and lint entry points

Run a focused selector first:

```sh
bin/rspec spec/requests/api/provider_suggestions_spec.rb
bin/rspec spec/models/claims/training_hours_spec.rb spec/models/claims/training_allowance_spec.rb
```

Use [ADR 3](../../adr/00003-testing-practices.md): unit specs for models/jobs/services, system specs for user journeys, request specs for endpoints. Tag new request and system specs `service: :claims` so the correct host is selected.

The current [CI test workflow](../../.github/workflows/build_and_test.yml) runs:

```sh
bundle exec rails test:prepare parallel:setup zeitwerk:check parallel:spec
```

This prepares test databases and runs the full parallel suite. Do not run it against a database containing data you need.

For non-mutating lint checks:

```sh
bundle exec rubocop
bundle exec erb_lint app
```

[bin/lint](../../bin/lint) enables autocorrection and can change files. Review its diff rather than using it as a read-only check.

These commands are onboarding instructions, not a claim that the Rails suite or fresh-machine setup was executed for this documentation change.

## Navigating and changing the code

Start with [architecture](architecture.md), [data model](data-model.md), [lifecycle](claim-lifecycle.md) and [ADR index](../../adr/README.md).

Service-specific code is namespaced `Claims::`; shared models and framework helpers live outside that namespace. School, provider and support user types share the users table. Do not assume one person has only one role.

Use [conventions](../conventions.md) for intent, but inspect the real classes before copying older examples:

- [BaseWizard](../../app/wizards/base_wizard.rb) accepts `state:`, not `session:`. [The current add-claim controller](../../app/controllers/claims/schools/claims/add_claim_controller.rb) selects per-journey session state and passes it into the wizard.
- [AddClaimWizard](../../app/wizards/claims/add_claim_wizard.rb) delegates final creation to services. New school claims are submitted; support can create drafts.
- [ApplicationService](../../app/services/application_service.rb) exposes `.call`; old illustrative `.new` comments are not the public entry point.
- [ApplicationForm](../../app/forms/application_form.rb) is under forms, even where an old convention tree shows components.

## First change and handover walkthrough

1. Trace one claims route through controller, policy, wizard/service and model.
2. Read its request/unit/system specs before editing.
3. Run focused tests and check the diff.
4. Update the linked contract, lifecycle or ERD if behaviour changes.
5. In an authorised non-production environment, locate logs, SHA, jobs and feature flags using [operations](operations.md).
6. Explain deployment and recovery with the outgoing team. Record unresolved access or procedure questions in the [audit](documentation-audit.md).

Local boot, test execution and access checks on the receiving team's machines remain handover acceptance steps.
