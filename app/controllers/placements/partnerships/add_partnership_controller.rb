class Placements::Partnerships::AddPartnershipController < Placements::ApplicationController
  include WizardController

  before_action :set_organisation
  before_action :set_wizard

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.create_partnership
      if @wizard.organisation.is_a?(Placements::School)
        Placements::Partnerships::Notify::Create.call(
          source_organisation: @wizard.organisation,
          partner_organisation: @wizard.partner_organisation,
        )
      end
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success_heading"),
        body: t(".success_body", partner_name: @wizard.partner_organisation.name),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddPartnershipWizard.new(organisation: @organisation, params:, state:, current_step:)
  end
end
