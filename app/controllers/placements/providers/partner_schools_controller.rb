class Placements::Providers::PartnerSchoolsController < Placements::PartnershipsController
  before_action :redirect_to_school_options, only: :check, if: -> { javascript_disabled? }

  def index
    @pagy, @partner_schools = pagy(@provider.partner_schools.order_by_name)
  end

  def school_options
    render_partner_organisation_options
  end

  def check_school_option
    check_partner_organisation_options
  end

  def create
    super

    flash[:success] = t(".partner_school_added")
  end

  def destroy
    super

    flash[:success] = t(".partner_school_removed")
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

  def redirect_to_school_options
    redirect_to school_options_placements_provider_partner_schools_path(
      partnership: { search_param: },
    )
  end

  def partnership_form(javascript_disabled: false)
    @partnership_form ||= ::Placements::PartnershipForm.new(
      school_id: partner_school_params[:school_id],
      provider_id: @provider.id,
      javascript_disabled:,
      form_input: :school_id,
    )
  end

  def partner_school
    @partner_school ||= partnership_form.school.decorate
  end
  alias_method :partner_organisation, :partner_school

  def javascript_disabled?
    params.dig(:partnership, :school_name).nil? && partner_school_params[:school_id].present?
  end

  def partner_school_params
    @partner_school_params ||= params.require(:partnership).permit(:school_id, :search_param, :school_name)
  end

  def search_param
    @search_param ||= partner_school_params[:search_param] || partner_school_params[:school_id]
  end

  def decorated_school_options
    @decorated_school_options ||= School.search_name_urn_postcode(
      search_param.downcase,
    ).map(&:decorate)
  end

  def redirect_to_check_path
    redirect_to check_placements_provider_partner_schools_path(
      partnership: { school_id: partner_school_params.fetch(:school_id), school_name: search_param },
    )
  end

  def redirect_to_index_path
    redirect_to placements_provider_partner_schools_path(@provider)
  end

  def back_link
    @back_link ||= new_placements_provider_partner_school_path(
      partnership_form.as_form_params,
    )
  end

  def new_partnership_form
    ::Placements::PartnershipForm.new(
      provider_id: @provider.id,
      form_input: :school_id,
    )
  end

  def render_partner_organisation_options
    render :school_options, locals: {
      search_param:,
      schools: decorated_school_options,
      school_form: partnership_form(javascript_disabled: true),
    }
  end
end
