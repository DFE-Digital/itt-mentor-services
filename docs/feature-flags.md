# Feature flags

## General principles

- We use the gem [Flipflop](https://github.com/voormedia/flipflop) to manage feature flags
- Developers are responsible for changing / maintaining feature flags using rake tasks

## How to

### Create a feature flag

- Add the feature to `features.rb` There is a basic example in the comments of that doc. See [Flipflop](https://github.com/voormedia/flipflop) docs for more detail.
- The feature will be turned off by default.
- Start using it in your code
- Use Rake tasks (see below) to enable / disable feature flags.

### Use in the codebase

Anywhere in the codebase, you can check to see if a feature is enabled.
For example, to check if a feature called `test_feature` is enabled you could use:

`Flipflop.test_feature?` or `Flipflop.enabled?(:test_feature)`

### Remove a feature flag

Once a feature flag has been turned on globally and everyone is happy that it should be a permanent feature the developer should:

- Remove all uses from the codebase
- Clear the feature flag from Active Record using the `flipflop:clear` rake task below in all environments.
- Delete the feature flag from `features.rb`

### Rake tasks

| Command                                                                                                    | Description                                                                                                                                   |
| ---------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `rake flipflop:features`                                                                                   | Shows features table                                                                                                                          |
| `rake "flipflop:turn_on[feature,strategy]"`<br/> eg `rake "flipflop:turn_on[test_feature,active_record]"`  | Enables a feature with the specified strategy<br/>Creates a record in the database if it does not exist already.<br/>Sets `enabled` to true   |
| `rake "flipflop:turn_on[feature,strategy]"`<br/> eg `rake "flipflop:turn_off[test_feature,active_record]"` | Disables a feature with the specified strategy<br/>Creates a record in the database if it does not exist already.<br/>Sets `enabled` to false |
| `rake "flipflop:clear[feature,strategy]"`<br/> eg `rake "flipflop:clear[test_feature,active_record]"`      | Clears a feature with the specified strategy<br/>Removes record from the database if it exists.                                               |

## Last reviewed

12-12-2023
