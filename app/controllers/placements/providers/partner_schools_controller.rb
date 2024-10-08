class Placements::Providers::PartnerSchoolsController < Placements::PartnershipsController
  def index
    @pagy, @partner_schools = pagy(partner_schools.order_by_name)
  end

  def destroy
    super

    flash[:heading] = t(".success_heading")
    flash[:body] = t(".success_body", school_name: @partner_school.name)
  end

  private

  def set_organisation
    set_provider
  end

  def source_organisation
    @provider
  end

  def set_decorated_partner_organisation
    @partner_school = partner_schools.find(params.require(:id)).decorate
  end

  def partner_schools
    policy_scope(
      @provider.partner_schools,
      policy_scope_class: Placements::Partnership::SchoolPolicy::Scope,
    )
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
