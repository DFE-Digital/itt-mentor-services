[All Conventions](/docs/conventions.md) / Service Objects

# Service Objects

> Service Objects provide a reusable interface to manipulating data and performing side effects.

## File Structure

```
app
└── services
    └── user
        ├── invite.rb # User::Invite.new(user:)
        └── remove.rb # User::Remove.new(user:)
```

## Naming Conventions

```
[Model]::[Verb].rb
```
