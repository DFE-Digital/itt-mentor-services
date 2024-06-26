class Placements::Support::Schools::PartnerProvidersController < Placements::Schools::PartnerProvidersController
  private

  def set_school
    @school = Placements::School.find(params.fetch(:school_id))
  end

  def redirect_to_check_path
    redirect_to check_placements_support_school_partner_providers_path(
      partnership: { provider_id: partner_provider_params.fetch(:provider_id), provider_name: search_param },
    )
  end

  def redirect_to_index_path
    redirect_to placements_support_school_partner_providers_path(@school)
  end

  def redirect_to_provider_options
    redirect_to provider_options_placements_support_school_partner_providers_path(
      partnership: { search_param: },
    )
  end

  def back_link
    @back_link ||= new_placements_support_school_partner_provider_path(
      partnership_form.as_form_params,
    )
  end
end
