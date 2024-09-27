class Placements::Schools::PartnerProvidersController < Placements::PartnershipsController
  def index
    scope = policy_scope(@school.partner_providers)
    @pagy, @partner_providers = pagy(scope.order_by_name)
  end

  def destroy
    super

    flash[:heading] = t(".success_heading")
    flash[:body] = t(".success_body", partner_name: @partner_provider.name)
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

  def partner_provider
    @partner_provider ||= partnership_form.provider.decorate
  end
  alias_method :partner_organisation, :partner_provider

  def redirect_to_index_path
    redirect_to placements_school_partner_providers_path(@school)
  end
end
