# 9. Wizards

Date: 2024-07-10

## Status

Accepted

## Context

Digital services that follow the [GOV.UK service standard][1] tend to make heavy use of multi-step forms. This is [considered best practice][2] because it breaks down complex tasks into smaller, easier to follow steps – for example, when [publishing a school placement][3], or [claiming funding for mentor training][4].

This is commonly known as the [Wizard design pattern][5].

### Rails is CRUD

Ruby on Rails is optimised for building CRUD applications and RESTful APIs. It has strong conventions that make it easy to create [resourceful routes][6].

But this all depends on an assumption that the 'create' step of CRUD happens in one single HTTP request. In other words, it depends on the user submitting a single form which maps cleanly to creating a thing in the application.

By their nature, wizards don't cleanly fit into that model. Users submit several forms, split across several pages, and the resultant object can only be created once the user has completed every step of the wizard. If you're not careful, you can easily end up fighting the framework as you try to shoehorn wizard behaviour into a CRUD controller.

We've therefore found it helpful to abstract common wizard behaviour into a set of classes and conventions that make it easier to build multi-step forms in our service.

### Options for building wizards in Rails

One common approach for implementing multi-step forms is to build them as 'single page apps' using JavaScript, then submit everything to the 'create' endpoint as one single payload. But this is not an option for us because government digital services need to [work without JavaScript][7].

For building server-side wizards, there are various opinions and patterns around. Some of these have been packaged up into Ruby gems – for example:

- [Wicked](https://github.com/zombocom/wicked)
- [DfE Wizard](https://github.com/DFE-Digital/dfe-wizard)
- [GOV.UK Wizardry](https://github.com/DFE-Digital/govuk-wizardry) _\*(not an official GOV.UK project)_

I spent some time investigating the features these gems offer, and the advantages and disadvantages of each approach.

#### Wicked

- 👍 Steps are defined as a linear journey
- 👍 Steps can be conditional
- 😕 The wizard is defined within the controller – this makes unit testing and code reuse more difficult
- 👎 No help with persisting the wizard state between page loads
- 👎 No help with building forms or validating user input

**Summary:** Wicked primarily just provides navigation helpers for moving users through a series of steps. When it comes to rendering, validating and persisting forms, you're on your own.

#### DfE Wizard

- 👍 Wizards and steps are defined in a standalone class, outside of the controller – this is great for unit testing and code reuse
- 👍 Steps can be conditional
- 👍 Each step is a [form object][9], so Active Model validation is baked in
- 😕 Each step decides what its next and previous steps are (a [doubly linked list][8]) – this works well for complex branching journeys, but for simpler journeys it's difficult to get a high-level overview of the end-to-end journey
- 😕 Supports persisting the wizard state between page loads – although it seems to be based on an assumption that you'll be iteratively building and saving partial objects to the database (which isn't always desirable)

**Summary:** DfE Wizard provides a nice structure for defining wizards and the steps they contain. It leans on established patterns like form objects. But it seems to be geared towards storing partial objects in the database as a means of persisting the wizard state.

#### GOV.UK Wizardry

- 😕 The entire wizard is defined inside the controller – this makes unit testing and code reuse more difficult
- 😕 Pages and questions are defined _and rendered_ using specialised Wizardry classes – while it's possible to use Rails `.html.erb` views, these are only intended to be used by exception
- 😕 The gem comes tightly coupled to its sister gems, [GOV.UK Components][10] and [GOV.UK Form Builder][11]
- 😕 Each wizard is coupled to an Active Record model, where each question is represented as a field on the model – this makes it difficult to build wizards which create different types of objects depending on the user's input, or don't create anything at all
- 👎 Limited documentation on how to use it
- 👎 May not be production ready – the [project README][12] says:
  > Note this library is at the very early stages of development. It's not properly tested and is very likely to change.

**Summary:** GOV.UK Wizardry is highly opinionated and designed to meet a very specific need – to build multi-step forms made of [GOV.UK Design System][13] components, without needing to write any HTML code, that will progressively save to an Active Record object.

## Decision

After having investigated the available options, my key learnings are this – wizard gems are more useful the more opinionated they are, but only if those opinions meet your specific needs. The less opinionated they are (for example, the Wicked gem), the less helpful they are.

### Key principles

We came up with some key principles for wizards in our service:

#### 1. Wizards store their state in the session

We want to store the state of wizards in the current user's session. This means we avoid the potential for partially-complete Active Record objects to pollute the database, which would be likely if the wizard progressively populates and persists objects.

By doing this, we avoid the need to retrospectively sweep through database tables and 'clean up' old, abandoned or incomplete records. Instead, we'll delegate that responsibility to the session, which is a temporary storage mechanism by its very nature.

#### 2. Wizards won't always create a thing

We foresee a need for wizards which don't end by creating a new thing in the database.

Sometimes they'll need to update existing records. For example, a wizard could be used to allocate mentors to an existing placement.

There could even be a need for wizards which don't write _anything_ to the database. For example, it could power a decision tree which ends by redirecting you to the correct location. Or to power an introductory onboarding flow for new users to the service.

#### 3. Wizards should be reusable

Digital services in DfE tend to have a built-in support console. This is an interface which support users can use to administer the service.

Many of the tasks users perform – for example, adding new users to their organisation, or publishing new school placements – also need to be available to support users in the support console.

By separating wizards from the controllers that implement them, we'd open up the possibility of re-using wizards in different contexts without needing to re-implement the journey or individual steps. For example, it'd be possible to build an "Add placement" wizard which both school users and support users have access to from their respective controllers.

### The responsibilities of a wizard

We have defined the following boundaries for controllers, wizards and steps:

#### Controller

Concerned with routing and navigating the user through the journey.

- Initialises the wizard and give it the context it needs
- Knows how to map steps to URL paths – for example, using a route helper with a 'step' parameter
- Resets the wizard's state at the beginning and end of journeys
- At the end of the journey, persists the resultant object and perform any required side-effects – for example, sending a notification email to the user

#### Wizard

Concerned with the overall flow of the form – defining the order of steps, persisting state, and initialising step objects.

- Controller agnostic – it doesn't know about the HTTP request, routing concerns, or even which page it's being rendered on
- Defines the journey that users take through the form – including skipping steps that aren't necessary under certain circumstances
- Determines what the previous and next steps are for the given current step
- Journeys are linear and defined centrally – it's therefore possible to see every step of the journey, in order, and defined in one single place
- Stores the state of each step into the session
- Makes steps available to each other – for example, so one step can change based on a previous step's state

#### Step

Concerned with individual fields and questions, and validating the user's input.

- Behaves like a form object or Active Model object, with attributes and validation rules
- Controller agnostic _and_ wizard agnostic
- Coupled to a view partial which renders the form
- May contain helper or decorator methods used by the view partial

## Consequences

Given all of the above, we have come up with a pattern for implementing wizards in our application. It loosely follows the structure of the DfE Wizard gem, where wizards and steps are standalone classes. But it stores its state in the session, and the wizard itself is responsible for the user's journey through the form.

For a concrete implementation, see this pull request which establishes the pattern and implements an "Add placement" wizard:

https://github.com/DFE-Digital/itt-mentor-services/pull/810

### When will this become a gem?

Never! 😄 This pattern suits our needs, but it comes with its own set of opinions. It's also fairly lightweight and would be easy to replicate in another Rails application if it's deemed to be a helpful pattern.

[1]: https://www.gov.uk/service-manual/service-standard
[2]: https://www.gov.uk/service-manual/design/form-structure
[3]: https://becoming-a-teacher.design-history.education.gov.uk/manage-school-placements/adding-placements/#adding-a-placement
[4]: https://becoming-a-teacher.design-history.education.gov.uk/claim-funding-for-mentors/submitting-claims-for-funding/#adding-a-claim
[5]: https://www.nngroup.com/articles/wizards/
[6]: https://guides.rubyonrails.org/routing.html#resource-routing-the-rails-default
[7]: https://www.gov.uk/service-manual/technology/using-progressive-enhancement
[8]: https://www.devx.com/terms/doubly-linked-list/
[9]: https://dev.to/vladhilko/how-to-implement-form-object-pattern-in-ruby-on-rails-5gi3
[10]: https://govuk-components.netlify.app
[11]: https://govuk-form-builder.netlify.app
[12]: https://github.com/DFE-Digital/govuk-wizardry/blob/3283ac9eb9d453a354cfa5e93a00572bc27e29ef/README.md
[13]: https://design-system.service.gov.uk
