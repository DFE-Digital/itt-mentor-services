class Placements::Support::ProvidersController < Placements::ApplicationController
  before_action :redirect_to_provider_options, only: :check, if: -> { javascript_disabled? }

  def new
    @provider_form = if params[:provider].present?
                       provider_form
                     else
                       ProviderOnboardingForm.new
                     end
  end

  def show
    @provider = Placements::Provider.find(params.require(:id)).decorate
  end

  def check
    if provider_form.valid?
      provider
      back_link
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
      redirect_to check_placements_support_providers_path(
        provider: { id: provider_params.fetch(:id), name: search_param },
      )
    else
      render :provider_options, locals: {
        search_param:,
        providers: decorated_provider_options,
        provider_form: provider_form(javascript_disabled: true),
      }
    end
  end

  def create
    provider_form.save!
    flash[:success] = I18n.t("placements.support.providers.create.organisation_added")
    redirect_to placements_support_organisations_path
  end

  private

  def javascript_disabled?
    provider_params[:name].nil? && provider_params[:id].present?
  end

  def redirect_to_provider_options
    redirect_to provider_options_placements_support_providers_path(
      provider: { search_param: },
    )
  end

  def provider_params
    @provider_params ||= params.require(:provider).permit(:id, :search_param, :name)
  end

  def search_param
    provider_params[:search_param] || provider_params[:id]
  end

  def provider_form(javascript_disabled: false)
    @provider_form ||= ProviderOnboardingForm.new(
      id: provider_params[:id],
      javascript_disabled:,
    )
  end

  def provider
    @provider ||= provider_form.provider.decorate
  end

  def decorated_provider_options
    @decorated_provider_options ||= Provider.search_name_urn_ukprn_postcode(
      search_param.downcase,
    ).map(&:decorate)
  end

  def back_link
    @back_link ||= new_placements_support_provider_path(provider_form.as_form_params)
  end
end
