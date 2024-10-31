class Placements::Organisations::Users::AddUserController < Placements::ApplicationController
  include WizardController

  before_action :set_organisation
  before_action :set_wizard

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      user = @wizard.create_user
      User::Invite.call(user:, organisation: @organisation)
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success_heading"),
        body: t(".success_body", user_name: user.full_name),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddUserWizard.new(organisation: @organisation, params:, state:, current_step:)
  end
end
