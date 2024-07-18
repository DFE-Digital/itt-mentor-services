class Placements::Support::Providers::PartnerSchools::AddPartnerSchoolController < Placements::Partnerships::AddPartnershipController
  private

  def set_organisation
    provider_id = params.fetch(:provider_id)
    @organisation = Placements::Provider.find(provider_id)
  end

  def step_path(step)
    add_partner_school_placements_support_provider_partner_schools_path(step:)
  end

  def index_path
    placements_support_provider_partner_schools_path(@organisation)
  end
end
