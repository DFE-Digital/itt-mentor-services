class Placements::Schools::PartnerProvidersController < Placements::PartnershipsController
  before_action :authorize_school
  def index
    @pagy, @partner_providers = pagy(partner_providers.order_by_name)
  end

  def destroy
    super

    flash[:heading] = t(".success_heading")
    flash[:body] = t(".success_body", partner_name: @partner_provider.name)
  end

  private

  def set_organisation
    set_school
  end

  def source_organisation
    @school
  end

  def set_decorated_partner_organisation
    @partner_provider = partner_providers.find(params.require(:id)).decorate
  end

  def partner_providers
    policy_scope([:partnership, @school.partner_providers])
  end

  def set_partnership
    @partnership = @school.partnerships.find_by(provider_id: @partner_provider.id)
  end

  def partner_provider
    @partner_provider ||= partnership_form.provider.decorate
  end
  alias_method :partner_organisation, :partner_provider

  def redirect_to_index_path
    redirect_to placements_school_partner_providers_path(@school)
  end

  def authorize_school
    authorize @school, :index?, policy_class: Placements::Partnership::ProviderPolicy
  end
end
