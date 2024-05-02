class Placements::Providers::PartnerSchoolsController < ApplicationController
  before_action :set_provider
  before_action :set_decorated_partner_school, only: %i[show remove destroy]
  before_action :set_partnership, only: %i[show remove destroy]
  before_action :redirect_to_school_options, only: :check, if: -> { javascript_disabled? }

  def index
    @pagy, @partner_schools = pagy(@provider.partner_schools)
  end

  def new
    @partnership_form = if params[:partnership].present?
                          partnership_form
                        else
                          ::Placements::PartnershipForm.new(
                            provider_id: @provider.id,
                            form_input: :school_id,
                          )
                        end
  end

  def check
    if partnership_form.valid?
      partner_school
    else
      render :new
    end
  end

  def school_options
    render locals: {
      search_param:,
      schools: decorated_school_options,
      school_form: ::Placements::PartnershipForm.new,
    }
  end

  def check_school_option
    if partnership_form(javascript_disabled: true).valid?
      redirect_to check_placements_provider_partner_schools_path(
        partnership: { school_id: partner_school_params.fetch(:school_id), school_name: search_param },
      )
    else
      render :school_options, locals: {
        search_param:,
        schools: decorated_school_options,
        school_form: partnership_form(javascript_disabled: true),
      }
    end
  end

  def create
    partnership_form.save!
    Placements::Partnerships::Notify::Create.call(
      source_organisation: @provider,
      partner_organisation: partner_school,
    )
    flash[:success] = t(".partner_school_added")
    redirect_to placements_provider_partner_schools_path(@provider)
  end

  def show; end

  def remove; end

  def destroy
    authorize @partnership

    school = @partnership.school
    @partnership.destroy!
    Placements::Partnerships::Notify::Remove.call(
      source_organisation: @provider,
      partner_organisation: school,
    )

    redirect_to placements_provider_partner_schools_path(@provider),
                flash: { success: t(".partner_school_removed") }
  end

  private

  def set_provider
    @provider = current_user.providers.find(params.fetch(:provider_id))
  end

  def set_decorated_partner_school
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
end
