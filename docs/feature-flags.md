# Feature flags

## General principles

- We use the gem [Flipper](https://github.com/flippercloud/flipper) to manage feature flags, note that we do not use Flipper cloud.
- Developers are responsible for changing and maintaining feature flags. The support-only Flipper UI is mounted at `/flipper`; see [routes](../config/routes.rb) and [claims operations](claims/operations.md).
- Confirm the environment, intended targeting and approval before changing a flag. Record its previous state and verify behaviour after the change.

## How to

### Create a feature flag

- Create a migration to create your feature flag in the database, you can use `Flipper.add(:feature_name)` to do this.
- The feature will be turned off by default.
- Start using it in your code
- Use the support UI or an approved, reviewed script to enable or disable flags. This guide does not define a repository-specific rake task contract.

### Use in the codebase

Anywhere in the codebase, you can check to see if a feature is enabled.
For example, to check if a feature called `test_feature` is enabled you could use:

`Flipper.enabled?(:test_feature)`

#### Enable a feature flag for specific actors

Sometimes we will need to roll out a feature to a selection of our users, but not all of them. We can target specific actors like so:

```ruby
Flipper.enable(:test_feature, selected_user)
```

Here `selected_user` must already be the explicitly verified actor. Do not use the first user in a database as a rollout target.

Note that this does not _need_ to be a user record, for example you may wish to enable a feature for anyone in a certain school. To check if the feature is enabled for an actor you can use:

```ruby
Flipper.enable(:test_feature, selected_school)

Flipper.enabled?(:test_feature, selected_school)
```

`selected_school` must be the explicitly verified school in the intended environment.

### Remove a feature flag

Once a feature flag has been turned on globally and everyone is happy that it should be a permanent feature the developer should:

- Remove all uses from the codebase
- Remove the flag from Active Record using the approved console/script call `Flipper.remove(:feature_name)` in all relevant environments, or create a migration. This method call is not a rake task.

## Last reviewed

24-02-2025
