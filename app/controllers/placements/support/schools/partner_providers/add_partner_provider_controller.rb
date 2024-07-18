class Placements::Support::Schools::PartnerProviders::AddPartnerProviderController < Placements::Partnerships::AddPartnershipController
  private

  def set_organisation
    school_id = params.require(:school_id)
    @organisation = Placements::School.find(school_id)
  end

  def step_path(step)
    add_partner_provider_placements_support_school_partner_providers_path(step:)
  end

  def index_path
    placements_support_school_partner_providers_path(@organisation)
  end
end
