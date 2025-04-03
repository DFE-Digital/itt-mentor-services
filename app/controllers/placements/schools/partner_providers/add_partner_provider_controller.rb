class Placements::Schools::PartnerProviders::AddPartnerProviderController < Placements::Partnerships::AddPartnershipController
  before_action :authorize_school

  private

  def set_organisation
    @organisation = set_school
  end

  def step_path(step)
    add_partner_provider_placements_school_partner_providers_path(state_key:, step:)
  end

  def index_path
    placements_school_partner_providers_path(@organisation)
  end

  def authorize_school
    authorize @organisation, :index?, policy_class: Placements::Partnership::ProviderPolicy
  end
end
