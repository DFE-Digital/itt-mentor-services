class Placements::Schools::PartnerProvidersController < Placements::PartnershipsController
  before_action :redirect_to_provider_options, only: :check, if: -> { javascript_disabled? }

  def index
    @pagy, @partner_providers = pagy(@school.partner_providers.order_by_name)
  end

  def provider_options
    render_partner_organisation_options
  end

  def check_provider_option
    check_partner_organisation_options
  end

  def create
    super

    flash[:success] = t(".partner_provider_added")
  end

  def destroy
    super

    flash[:success] = t(".partner_provider_removed")
  end

  private

  def set_organisation
    @school = current_user.schools.find(params.fetch(:school_id))
  end

  def source_organisation
    @school
  end

  def set_decorated_partner_organisation
    @partner_provider = @school.partner_providers.find(params.require(:id)).decorate
  end

  def set_partnership
    @partnership = @school.partnerships.find_by(provider_id: @partner_provider.id)
  end

  def redirect_to_provider_options
    redirect_to provider_options_placements_school_partner_providers_path(
      partnership: { search_param: },
    )
  end

  def partnership_form(javascript_disabled: false)
    @partnership_form ||= ::Placements::PartnershipForm.new(
      school_id: @school.id,
      provider_id: partner_provider_params[:provider_id],
      javascript_disabled:,
      form_input: :provider_id,
    )
  end

  def partner_provider
    @partner_provider ||= if @partnership.present?
                            @partnership.provider
                          else
                            partnership_form.provider.decorate
                          end
  end
  alias_method :partner_organisation, :partner_provider

  def javascript_disabled?
    params.dig(:partnership, :provider_name).nil? && partner_provider_params[:provider_id].present?
  end

  def partner_provider_params
    @partner_provider_params ||= params.require(:partnership).permit(:provider_id, :search_param, :provider_name)
  end

  def search_param
    @search_param ||= partner_provider_params[:search_param] || partner_provider_params[:provider_id]
  end

  def decorated_provider_options
    @decorated_provider_options ||= Provider.search_name_urn_ukprn_postcode(
      search_param.downcase,
    ).map(&:decorate)
  end

  def redirect_to_check_path
    redirect_to check_placements_school_partner_providers_path(
      partnership: { provider_id: partner_provider_params.fetch(:provider_id), provider_name: search_param },
    )
  end

  def redirect_to_index_path
    redirect_to placements_school_partner_providers_path(@school)
  end

  def back_link
    @back_link ||= new_placements_school_partner_provider_path(
      partnership_form.as_form_params,
    )
  end

  def new_partnership_form
    ::Placements::PartnershipForm.new(
      school_id: @school.id,
      form_input: :provider_id,
    )
  end

  def render_partner_organisation_options
    render :provider_options, locals: {
      search_param:,
      providers: decorated_provider_options,
      provider_form: partnership_form(javascript_disabled: true),
    }
  end
end
