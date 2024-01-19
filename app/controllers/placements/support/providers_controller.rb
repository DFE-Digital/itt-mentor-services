class Placements::Support::ProvidersController < Placements::Support::ApplicationController
  before_action :redirect_to_provider_options, only: :check, if: -> { javascript_disabled? }

  def new
    @provider_form = ProviderOnboardingForm.new
  end

  def show
    @provider = Placements::Provider.find(params.require(:id)).decorate
  end

  def check
    if provider_form.valid?
      provider
    else
      render :new
    end
  end

  def provider_options
    render locals: {
      search_param:,
      providers: decorated_provider_options,
      provider_form: ProviderOnboardingForm.new,
    }
  end

  def check_provider_option
    if provider_form(javascript_disabled: true).valid?
      redirect_to check_placements_support_providers_path(provider: { search_code: provider_code })
    else
      render :provider_options, locals: {
        search_param:,
        providers: decorated_provider_options,
        provider_form: provider_form(javascript_disabled: true),
      }
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

  def redirect_to_provider_options
    redirect_to provider_options_placements_support_providers_path(
      provider: { search_param: provider_params[:code] },
    )
  end

  def provider_params
    @provider_params ||= params.require(:provider).permit(
      :code, :search_param, :search_code
    )
  end

  def provider_param
    provider_params[:search_param] || params[:search_param]
  end

  def javascript_disabled?
    provider_params[:search_code].nil? && provider_params[:code].present?
  end

  def provider_form(javascript_disabled: false)
    @provider_form ||= ProviderOnboardingForm.new(code: provider_code)
  end

  def provider
    @provider ||= provider_form.provider.decorate
  end

  def provider_code
    params.dig(:provider, :search_code) || provider_params[:code]
  end

  def search_param
    provider_params[:search_param] || params[:search_param]
  end

  def decorated_provider_options
    @decorated_provider_options ||= Provider.search_name_urn_ukprn_postcode(
      search_param.downcase,
    ).map(&:decorate)
  end
end
