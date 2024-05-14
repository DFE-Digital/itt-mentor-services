class Placements::Support::Providers::PartnerSchoolsController < Placements::Providers::PartnerSchoolsController
  def destroy
    authorize @partnership

    @partnership.destroy!
    redirect_to placements_support_school_partner_providers_path(@school),
                flash: { success: t(".partner_provider_removed") }
  end

  private

  def set_school
    @school = Placements::School.find(params.fetch(:school_id))
  end

  def redirect_to_check_path
    redirect_to check_placements_support_school_partner_provider_path(
      partnership: { provider_id: partner_provider_params.fetch(:provider_id), provider_name: search_param },
    )
  end

  def redirect_to_index_path
    redirect_to placements_support_school_partner_providers_path(@school)
  end
end
