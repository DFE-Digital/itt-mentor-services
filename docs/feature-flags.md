# Feature flags

## General principles

- We use the gem [Flipper](https://github.com/flippercloud/flipper) to manage feature flags, note that we do not use Flipper cloud.
- Developers are responsible for changing / maintaining feature flags using rake tasks

## How to

### Create a feature flag

- Create a migration to create your feature flag in the database, you can use `Flipper.add(:feature_name)` to do this.
- The feature will be turned off by default.
- Start using it in your code
- Use Rake tasks (see below) to enable / disable feature flags.

### Use in the codebase

Anywhere in the codebase, you can check to see if a feature is enabled.
For example, to check if a feature called `test_feature` is enabled you could use:

`Flipper.enabled?(:test_feature)`

#### Enable a feature flag for specific actors

Sometimes we will need to roll out a feature to a selection of our users, but not all of them. We can target specific actors like so:

```ruby
user = User.first
Flipper.enable(:test_feature, user)
```

Note that this does not _need_ to be a user record, for example you may wish to enable a feature for anyone in a certain school. To check if the feature is enabled for an actor you can use:

```ruby
user = User.first
school = Placements::School.first(users: [user])
Flipper.enable(:test_feature, school)

Flipper.enabled?(:test_feature, user.school)
```

### Remove a feature flag

Once a feature flag has been turned on globally and everyone is happy that it should be a permanent feature the developer should:

- Remove all uses from the codebase
- Clear the feature flag from Active Record using the `Flipper.remove(:feature_name)` rake task below in all environments (or create a migration).

## Last reviewed

24-02-2025
