class Placements::Schools::PartnerProviders::AddPartnerProviderController < Placements::Partnerships::AddPartnershipController
  private

  def set_organisation
    school_id = params.require(:school_id)
    @organisation = current_user.schools.find(school_id)
  end

  def step_path(step)
    add_partner_provider_placements_school_partner_providers_path(step:)
  end

  def index_path
    placements_school_partner_providers_path(@organisation)
  end
end
