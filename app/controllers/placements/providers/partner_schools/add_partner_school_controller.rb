class Placements::Providers::PartnerSchools::AddPartnerSchoolController < Placements::Partnerships::AddPartnershipController
  private

  def set_organisation
    @organisation = set_provider
  end

  def step_path(step)
    add_partner_school_placements_provider_partner_schools_path(state_key:, step:)
  end

  def index_path
    placements_provider_partner_schools_path(@organisation)
  end
end
