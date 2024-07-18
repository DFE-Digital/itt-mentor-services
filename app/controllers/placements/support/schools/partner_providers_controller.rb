class Placements::Support::Schools::PartnerProvidersController < Placements::Schools::PartnerProvidersController
  private

  def set_organisation
    @school = Placements::School.find(params.fetch(:school_id))
  end

  def redirect_to_index_path
    redirect_to placements_support_school_partner_providers_path(@school)
  end
end
