class Placements::Support::ProvidersController < Placements::Support::ApplicationController
  def new
    @provider_form = ProviderOnboardingForm.new
  end

  def check
    if provider_form.valid?
      provider
    else
      render :new
    end
  end

  def create
    if provider_form.onboard
      flash[:success] = I18n.t("placements.support.providers.create.organisation_added")
      redirect_to placements_support_organisations_path
    else
      render :new
    end
  end

  private

  def provider_form
    @provider_form ||= ProviderOnboardingForm.new(code: provider_code)
  end

  def provider
    @provider ||= provider_form.provider.decorate
  end

  def provider_code
    params.dig(:provider, :search_code)
  end
end
