class Placements::Support::Providers::PartnerSchoolsController < Placements::Providers::PartnerSchoolsController
  private

  def set_provider
    @provider = Placements::Provider.find(params.fetch(:provider_id))
  end

  def redirect_to_check_path
    redirect_to check_placements_support_provider_partner_schools_path(
      partnership: { school_id: partner_school_params.fetch(:school_id), school_name: search_param },
    )
  end

  def redirect_to_index_path
    redirect_to placements_support_provider_partner_schools_path(@provider)
  end

  def redirect_to_school_options
    redirect_to school_options_placements_support_provider_partner_schools_path(
      partnership: { search_param: },
    )
  end
end
