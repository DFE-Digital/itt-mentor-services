class Placements::Support::OrganisationsController < Placements::Support::ApplicationController
  def index
    @schools = Placements::School.order(:name)
    @providers = Placements::Provider.all
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

  def organisation_type_param
    params.dig(:organisation, :organisation_type)
  end
end
