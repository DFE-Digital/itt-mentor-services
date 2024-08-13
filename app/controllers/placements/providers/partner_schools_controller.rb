class Placements::Providers::PartnerSchoolsController < Placements::PartnershipsController
  def index
    scope = policy_scope(@provider.partner_schools)
    @pagy, @partner_schools = pagy(scope.order_by_name)
  end

  def destroy
    super

    flash[:success] = t(".partner_school_deleted")
  end

  private

  def set_organisation
    @provider = current_user.providers.find(params.fetch(:provider_id))
  end

  def source_organisation
    @provider
  end

  def set_decorated_partner_organisation
    @partner_school = @provider.partner_schools.find(params.require(:id)).decorate
  end

  def set_partnership
    @partnership = @provider.partnerships.find_by(school_id: @partner_school.id)
  end

  def partner_school
    @partner_school ||= partnership_form.school.decorate
  end
  alias_method :partner_organisation, :partner_school

  def redirect_to_index_path
    redirect_to placements_provider_partner_schools_path(@provider)
  end
end
