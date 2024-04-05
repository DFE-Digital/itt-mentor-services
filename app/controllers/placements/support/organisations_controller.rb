class Placements::Support::OrganisationsController < Placements::Support::ApplicationController
  def index
    @pagy, @organisations = pagy(organisations)
    @filters = filters_param
  end

  def new
    @organisation_form = OrganisationOnboardingForm.new
  end

  def select_type
    @organisation_form = OrganisationOnboardingForm.new(
      organisation_type: organisation_type_param,
    )
    if @organisation_form.valid?
      redirect_to @organisation_form.onboarding_url
    else
      render :new
    end
  end

  private

  def organisations
    @organisations ||= Placements::OrganisationFinder.call(filters: filters_param, search_term: search_param)
  end

  def filters_param
    params.fetch(:filters, []).compact.reject(&:blank?)
  end

  def search_param
    params.fetch(:name_or_postcode, "")
  end

  def organisation_type_param
    params.dig(:organisation, :organisation_type)
  end
end
