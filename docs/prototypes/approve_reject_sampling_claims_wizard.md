# Provider Sampling Claims Approval/Rejection Wizard

## Overview

Added a complete three-step wizard that allows providers in the prototype to approve or reject claims with `sampling_in_progress` status. This follows the established wizard pattern in the application.

## Feature Summary

### Workflow: Approve Claim
1. **Mentor Selection**: User selects which mentors from the claim to review
2. **Hours Confirmation**: For each selected mentor, user confirms the number of hours trained
3. **Review & Approve**: Summary page where user reviews selections and approves the claim
4. **Result**: Claim status updated to `paid` with claim activity logged

### Workflow: Reject Claim
1. **Mentor Selection**: User selects which mentors to reject
2. **Hours & Reason**: For each mentor, user confirms hours and provides a rejection reason
3. **Review & Reject**: Summary page where user reviews all details and rejects the claim
4. **Result**: Claim status updated to `sampling_provider_not_approved` with claim activity logged

## Claim Show Page

The prototype claim show page now displays approve and reject buttons when a claim has `status == "sampling_in_progress"`:

```erb
<% if @claim.status == "sampling_in_progress" %>
  <div class="govuk-button-group">
    <%= govuk_link_to("Approve claim", ..., button: true) %>
    <%= govuk_link_to("Reject claim", ..., button: true, secondary: true) %>
  </div>
<% end %>
```

## Navigation Routes

```ruby
namespace :user_research, path: "user-research" do
  resources :provider_claims, path: "provider/claims", only: %i[index show] do
    member do
      get "approve_claim/new", to: "sampling_claims/approve#new", as: :new_approve_claim
      get "approve_claim/new/:state_key/:step", to: "sampling_claims/approve#edit", as: :approve_claim
      put "approve_claim/new/:state_key/:step", to: "sampling_claims/approve#update"

      get "reject_claim/new", to: "sampling_claims/reject#new", as: :new_reject_claim
      get "reject_claim/new/:state_key/:step", to: "sampling_claims/reject#edit", as: :reject_claim
      put "reject_claim/new/:state_key/:step", to: "sampling_claims/reject#update"
    end
  end
end
```

## File Structure

### Wizard Classes
- `app/wizards/claims/user_research/approve_reject_sampling_claim_wizard.rb` - Main wizard class
- `app/wizards/claims/user_research/approve_reject_sampling_claim_wizard/mentor_step.rb` - Step 1: Mentor selection
- `app/wizards/claims/user_research/approve_reject_sampling_claim_wizard/mentor_training_step.rb` - Step 2: Hours/reason entry
- `app/wizards/claims/user_research/approve_reject_sampling_claim_wizard/check_your_answers_step.rb` - Step 3: Review

### Controllers
- `app/controllers/claims/user_research/sampling_claims/approve_controller.rb` - Approve flow
- `app/controllers/claims/user_research/sampling_claims/reject_controller.rb` - Reject flow

### Views
- `app/views/wizards/claims/user_research/approve_reject_sampling_claim_wizard/_mentor_step.html.erb`
- `app/views/wizards/claims/user_research/approve_reject_sampling_claim_wizard/_mentor_training_step.html.erb`
- `app/views/wizards/claims/user_research/approve_reject_sampling_claim_wizard/_check_your_answers_step.html.erb`
- `app/views/claims/user_research/sampling_claims/approve/edit.html.erb`
- `app/views/claims/user_research/sampling_claims/reject/edit.html.erb`

### Localization
- `config/locales/en/wizards/claims/user_research/approve_reject_sampling_claim_wizard.yml`
- `config/locales/en/claims/user_research/sampling_claims/approve.yml`
- `config/locales/en/claims/user_research/sampling_claims/reject.yml`

### Tests
- `spec/requests/claims/user_research/sampling_claims_spec.rb` - 7 passing tests covering:
  - Approve workflow entry point
  - Reject workflow entry point
  - Complete approve flow
  - Complete reject flow
  - Rejection reason validation
  - Approve/reject buttons display on sampling_in_progress claims
  - Buttons hidden for non-sampling claims

## Key Design Decisions

### 1. Prototype-Aware Claim Activity
The wizard checks if `current_user.is_a?(Claims::SupportUser)` before creating claim activity. Since the prototype uses a `ProviderProfile` struct instead of a real user, this allows the wizard to work in both contexts:
- In production: Creates proper audit trail
- In prototype: Skips creation (no user to associate)

### 2. Hours Validation
- Mentor training step validates `hours_completed` is an integer > 0
- For rejection: Additional validation requires `reason_not_assured` to be present
- Max hours pulled from existing mentor training record

### 3. Step Progression
- Mentor step always comes first
- Per-mentor steps loop dynamically based on selected mentors
- Check-your-answers final step shows all selections with change links

### 4. Rejection Reason Field
- Only shown in rejection flow (conditional in view)
- Validated only when action is "reject"
- Included in final provider responses sent to claim update service

## Test Coverage

All 7 tests pass:
```
Provider sampling claims approval/rejection wizard
  ✓ GET /user-research/provider/claims/:id/approve_claim/new redirects to the first approve wizard step
  ✓ GET /user-research/provider/claims/:id/reject_claim/new redirects to the first reject wizard step
  ✓ Approve wizard flow guides through mentor selection, hours confirmation, and approval
  ✓ Reject wizard flow guides through mentor selection, hours and reason confirmation, and rejection
  ✓ Reject wizard flow requires a rejection reason
  ✓ Show page approve/reject buttons displays approve and reject buttons for sampling_in_progress claims
  ✓ Show page approve/reject buttons does not display buttons for non-sampling claims
```

## Next Steps (Optional)

Potential enhancements:
1. Add system tests for UI interactions (form submission, validation messages)
2. Add state machine visualization for claim status transitions
3. Create reusable "change answer" component for multiple steps
4. Add analytics tracking for wizard completion rates
