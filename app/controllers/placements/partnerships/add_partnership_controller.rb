class Placements::Partnerships::AddPartnershipController < Placements::ApplicationController
  before_action :set_organisation
  before_action :set_wizard

  helper_method :step_path, :current_step_path, :back_link_path

  def new
    redirect_to step_path(@wizard.first_step)
  end

  def edit; end

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.create_partnership
      Placements::Partnerships::Notify::Create.call(
        source_organisation: @wizard.organisation,
        partner_organisation: @wizard.partner_organisation,
      )
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

  def state_key
    @state_key ||= params.fetch(:state_key, Placements::BaseWizard.generate_state_key)
  end

  def current_step_path
    step_path(@wizard.current_step)
  end

  def back_link_path
    if @wizard.previous_step.present?
      step_path(@wizard.previous_step)
    else
      index_path
    end
  end
end
