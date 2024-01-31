[All Conventions](/docs/conventions.md) / Form Objects

# Form Objects

> Form Objects should validate that the acceptance criteria of a form has been met.

Form Objects are a complex representation of a Rails models and therefore should act as drop-in replacements for form submission purposes.

## File Structure

To support the scaling of forms, we should attempt to namespace the form objects by the core model.

```
app
└── components
    ├── organisation
    │   └── onboarding_form.rb # Organisation::OnboardingForm.new(organisation:)
    ├── user
    │   └── invitation_form.rb # User::InvitationForm.new(user:)
    └── application_form.rb # Base class for Form Objects
```

## Naming Convention

```
[Model]::[Noun]_form.rb
```

## ActiveRecord Duck-typing

To act as drop-in replacements for ActiveRecord instances, we need Form Objects to respond to the following methods:

- `errors` - Used to render errors on the form.
- `save` - Used by callers to persist the data submitted.

`ApplicationForm` implements `valid?` and `errors` out of the box, inherited from `ActiveModel::Model`.

`ApplicationForm` also implements `save` and `save!` to perform validations before calling `persist`.

We need to define `persist` to tell our app how to process a successful form submission. By default, `ApplicationForm` will just return `true`.

`save` should then be called in Controllers and [Service Objects](/docs/conventions/service_objects.md).

```ruby
class School::OnboardingForm < ApplicationForm
  attribute :id
  attribute :service

  validates :service, presence: true, inclusion: { in: %i[placements claims] }

  def persist
    school.update("#{service}_enabled": true)
  end

  private

  def school
    @school ||= School.find(id)
  end
end
```

## I18n

Use the local `t` method with `.`-prefixed keys. This will scope translations to the form component lookup path.

```ruby
class Organisation::OnboardingForm < ApplicationForm
  def save
    t(".success") # en.forms.organisation.onboarding_form.success
  end
end
```
