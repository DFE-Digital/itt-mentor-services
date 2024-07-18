class Placements::Support::Providers::PartnerSchoolsController < Placements::Providers::PartnerSchoolsController
  private

  def set_organisation
    @provider = Placements::Provider.find(params.fetch(:provider_id))
  end

  def redirect_to_index_path
    redirect_to placements_support_provider_partner_schools_path(@provider)
  end
end
