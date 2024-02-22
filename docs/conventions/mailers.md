[All Conventions](/docs/conventions.md) / Mailers

# Mailers

We follow standard Rails mailer conventions.

## File Structure

```
app
└── mailers
    ├── support_user_mailer.rb # SupportUserMailer
    └── user_mailer.rb # UserMailer
```

## Naming Conventions

To create consistency amongst our mailers, we have introduced some scalable conventions.

> ### The essence of a mailer
>
> To develop a naming convention, we must first reflect on how our code is being used, and look for some common patterns that apply to most use cases. In doing so, I’ve realised that most mailers can all be boiled down to these common features:
>
> #### Recipient
>
> The recipient is the entity that will receive the email. This will normally be a person, but it could also be another app or remote service that receives email inputs. Recipients might be your service users, customers, internal admins, or unauthenticated visitors to your website.
>
> ### Resource
>
> Emails are usually sent out to provide information about a specific resource or domain concept within the system. In other words, emails are usually sent about something relevant to some thing. An article has been published, a subscription has lapsed, a purchase has been completed. These will often be the models that you’ve defined in your code, but they might also be more abstract concepts (like a password reminder).
>
> #### Change
>
> Transactional emails don’t just spontaneously fire off. They’re usually sent in response to an event or some change that’s happened within the system. An example could be when some resource is created, updated, cancelled, or renewed.
>
> #### Intention
>
> Services email people for different reasons, which I’ve called the intention. In practice, using this convention, I’ve only ever come across four different intentions when sending emails: notification, confirmation, warning, and provision. You might discover more in your own use-cases, but I haven’t needed more than these in the past few months.
>
> By identifying these common patterns within our mailers, we can now try to establish a naming convention that communicates what an email is being sent for within our code.
>
> \- https://katanacode.com/blog/ruby-on-rails-action-mailer-how-to-name-mailer-methods/

```ruby
# <recipient>_mailer.rb
class <Recipient>Mailer < ApplicationMailer
  def <resource>_<change>_<intention>(recipient, *args)
    notify_mail to: recipient.email,
                subject: t(".subject"),
                body: t(".body")
  end
end
```

#### Example

```ruby
# <recipient>_mailer.rb
class UserMailer < ApplicationMailer
  def user_membership_created_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", organisation_name: organisation.name),
                 body: t(".body", user_name: user.full_name, organisation_name: organisation.name, service_name:, sign_in_url:)
  end
end
```

## Action Mailer

We use [ActionMailer](https://guides.rubyonrails.org/action_mailer_basics.html) model our emails.

## [GOV.UK Notify](https://www.notifications.service.gov.uk)

We use the GOV.UK service as our mailer backend to send emails via the [mail-notify](https://github.com/dxw/mail-notify) gem.

## Previews

Due to [a change](https://github.com/rails/rails/pull/45987) in Rails 7.1, we do not support previewing emails.
