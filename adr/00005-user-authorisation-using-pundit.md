# 5. User Authorisation using Pundit

Date: 2024-02-05

## Status

Accepted

## Context

We want to have scalable user authorisation and permissions. We started with conditional scoping and per-case permissions, such as the following code snippets:

- Permissions

  ```erb
  <% if user != current_user %>
    <%= link_to "Remove", remove_user_path(user) %>
  <% end %>
  ```

- Scopes

  ```ruby
  class SchoolsController
    def index
      @schools = scoped_schools
    end

    private

    def scoped_schools
      return School.all if current_user.support_user?

      current_user.schools
    end
  end
  ```

This logic is contained within Controllers and Views. This makes the logic both difficult to unit test and re-use.

## Decision

- Add the [Pundit](https://github.com/varvet/pundit) gem.
- Adopt the resource policies pattern.

## Consequences

Moving forward, user permissions should be defined within policy classes.

The above can now be re-written as:

```ruby
class UserPolicy < ApplicationPolicy
  def destroy?
    current_user.support_user? && user != current_user
  end
end

<% if policy(user).destroy? %>
  <%= link_to "Remove", remove_user_path(user) %>
<% end %>
```

and

```ruby
class SchoolPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.support_user?
        scope.all
      else
        scope.joins(:users).where(users: { id: user })
      end
    end
  end
end

class SchoolsController
  def index
    @schools = policy_scope(School)
  end
end
```
