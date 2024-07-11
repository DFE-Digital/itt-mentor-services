[All Conventions](/docs/conventions.md) / Wizards

# Wizards

> Use wizards to build multi-step forms that help users complete complex tasks

## File Structure

This directory tree represents a wizard and its steps:

```
app/
└── wizards/
    └── placements/
        ├── add_placement_wizard.rb
        └── add_placement_wizard/
            ├── check_your_answers_step.rb
            ├── mentors_step.rb
            └── subject_step.rb
```

## How to build a wizard

This is a simplified example to demonstrate the various parts that come together to make a wizard.

### 1. Create a wizard class

```ruby
# app/wizards/placements/add_placement_wizard.rb
module Placements
  class AddPlacementWizard < BaseWizard
    def define_steps
      # Define the wizard steps here
      add_step(SubjectStep)
      add_step(MentorsStep)
      add_step(CheckYourAnswersStep)
    end
  end
end
```

### 2. Create step classes

Think of step objects as a hybrid between form objects and decorators:

- **Form objects** – to hold attributes and validate their values
- **Decorators** – just like a ViewComponent's HTML markup comes coupled with a Ruby class, or how helpers and decorators are used by the view layer

```ruby
# app/wizards/placements/add_placement_wizard/subject_step.rb
class Placements::AddPlacementWizard::SubjectStep < Placements::BaseStep
  attribute :subject_id
  validates :subject_id, presence: true

  def subject_name
    Subject.find(subject_id).name
  end

  def subjects_for_selection
    Subject.all
  end
end
```

```ruby
# app/wizards/placements/add_placement_wizard/mentors_step.rb
class Placements::AddPlacementWizard::MentorsStep < Placements::BaseStep
  attribute :mentor_ids
  validates :mentor_ids, presence: true

  def mentors_for_selection
    Placements::Mentor.all
  end
end
```

```ruby
# app/wizards/placements/add_placement_wizard/check_your_answers_step.rb
class Placements::AddPlacementWizard::CheckYourAnswersStep < Placements::BaseStep
  # This step has no attributes of its own
end
```

### 3. Create view partials for each step

Each step comes coupled with a view partial.

```erb
# views/placements/wizards/add_placement_wizard/_subject_step.html.erb
<%= form_for(subject_step, url: current_step_path, method: :put) do |f| %>
  <%= f.govuk_error_summary %>

  <%= f.govuk_collection_radio_buttons(
    :subject_id,
    subject_step.subjects_for_selection,
    :id, :name,
    legend: { text: "Subject" }
  ) %>

  <%= f.govuk_submit "Continue" %>
<% end %>
```

```erb
# views/placements/wizards/add_placement_wizard/_mentors_step.html.erb
<%= form_for(mentors_step, url: current_step_path, method: :put) do |f| %>
  <%= f.govuk_error_summary %>

  <%= f.govuk_collection_check_boxes(
    :mentor_ids,
    mentors_step.mentors_for_selection,
    :id, :name,
    legend: { text: "Mentors" }
  ) %>

  <%= f.govuk_submit "Continue" %>
<% end %>
```

```erb
# views/placements/wizards/add_placement_wizard/_check_your_answers_step.html.erb
<%= form_for(check_your_answers_step, url: current_step_path, method: :put) do |f| %>
  <%= f.govuk_error_summary %>

  <%= govuk_summary_list do |summary_list| %>
    <% summary_list.with_row do |row| %>
      <% row.with_key(text: "Subject") %>
      <% row.with_value(text: @wizard.steps[:subject].subject_name) %>
      <% row.with_action(text: "Change", href: step_path(:subject), visually_hidden_text: "subject") %>
    <% end %>
    <% summary_list.with_row do |row| %>
      <% row.with_key(text: "Mentors") %>
      <% row.with_value(text: @wizard.steps[:mentors].mentor_ids) %>
      <% row.with_action(text: "Change", href: step_path(:mentors), visually_hidden_text: "mentors") %>
    <% end %>
  <% end %>

  <%= f.govuk_submit "Add placement" %>
<% end %>
```

### 4. Create a controller

The controller that will implement the wizard. You'll most likely need the following actions:

- `new` – to begin a fresh journey through the wizard
- `edit` – render a step
- `update` – validate form submission and update the wizard state

It's possible to re-use the same wizard across multiple controllers. This is handy, for example, when implementing the same flow for regular users and support users in the support console.

```ruby
class AddPlacementController < ApplicationController
  before_action :set_wizard

  helper_method :step_path, :current_step_path, :back_link_path

  def new
    @wizard.reset_state
    redirect_to step_path(@wizard.first_step)
  end

  def edit; end

  def update
    if !@wizard.save_step
      # There were validation errors – show them to the user
      render "edit"
    elsif @wizard.next_step.present?
      # The step was valid – redirect to the next step
      redirect_to step_path(@wizard.next_step)
    else
      # All steps completed – create the placement & reset the wizard's state.
      # e.g. @wizard.create_placement
      @wizard.reset_state
      redirect_to some_path, flash: { success: "Placement created" }
    end
  end

  private

  def set_wizard
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddPlacementWizard.new(params:, session:, current_step:)
  end

  def step_path(step)
    add_placement_placements_school_placements_path(step:)
  end

  def current_step_path
    step_path(@wizard.current_step)
  end

  def back_link_path
    if @wizard.previous_step.present?
      step_path(@wizard.previous_step)
    else
      some_path
    end
  end
end
```

### 5. Create a view for the controller

Wizard steps [respond to `#to_partial_path`](https://api.rubyonrails.org/classes/ActionView/PartialRenderer.html#class-ActionView::PartialRenderer-label-Rendering+objects+that+respond+to+to_partial_path) so are rendered using their associated view partials.

```erb
# views/add_placement/edit.html.erb
<%= content_for(:before_content) do %>
  <%= govuk_back_link(href: back_link_path) %>
<% end %>

<div class="govuk-width-container">
  <%= render @wizard.step, object: @wizard.step %>
</div>
```

### 6. Add routes for the controller

```diff
resources :placements, only: %i[index show destroy] do
  member { get :remove }

+  collection do
+    get "new", to: "add_placement#new", as: :new_add_placement
+    get "new/:step", to: "add_placement#edit", as: :add_placement
+    put "new/:step", to: "add_placement#update"
+  end
end
```

This results in URL paths like:

- Placements controller
  - `GET /placements` – see all placements
  - `GET /placements/:id` – show a placement's details
  - `GET /placements/:id/remove` – remove a placement
- "Add placement" controller
  - `GET /placements/new` – begin the "Add placement" journey
  - `GET /placements/new/:step` – edit a step of the wizard
  - `PUT /placements/new/:step` – update step and redirect to the next step

## Further reading

For an in-depth description of our approach to wizards, see [ADR 9. Wizards](/adr/00009-wizards.md).

For a more complete example, see the _actual_ ["Add placement" wizard](/app/wizards/placements/add_placement_wizard.rb).

To understand the behaviour and interface of wizards, see:

- **Wizard spec:** [spec/wizards/placements/base_wizard_spec.rb](/spec/wizards/placements/base_wizard_spec.rb)
- **Step spec:** [spec/wizards/placements/base_step_spec.rb](/spec/wizards/placements/base_step_spec.rb)
- **Mock wizard:** [spec/wizards/placements/burger_order_wizard_mock.rb](/spec/wizards/placements/burger_order_wizard_mock.rb) (used by the above specs)
