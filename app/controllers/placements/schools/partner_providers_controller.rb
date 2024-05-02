class Placements::Schools::PartnerProvidersController < ApplicationController
  before_action :set_school
  before_action :set_decorated_partner_provider, only: %i[show remove destroy]
  before_action :set_partnership, only: %i[show remove destroy]
  before_action :redirect_to_provider_options, only: :check, if: -> { javascript_disabled? }

  def index
    @pagy, @partner_providers = pagy(@school.partner_providers)
  end

  def new
    @partnership_form = if params[:partnership].present?
                          partnership_form
                        else
                          ::Placements::PartnershipForm.new(
                            school_id: @school.id,
                            form_input: :provider_id,
                          )
                        end
  end

  def check
    if partnership_form.valid?
      partner_provider
    else
      render :new
    end
  end

  def provider_options
    render locals: {
      search_param:,
      providers: decorated_provider_options,
      provider_form: ::Placements::PartnershipForm.new,
    }
  end

  def check_provider_option
    if partnership_form(javascript_disabled: true).valid?
      redirect_to check_placements_school_partner_providers_path(
        partnership: { provider_id: partner_provider_params.fetch(:provider_id), provider_name: search_param },
      )
    else
      render :provider_options, locals: {
        search_param:,
        providers: decorated_provider_options,
        provider_form: partnership_form(javascript_disabled: true),
      }
    end
  end

  def create
    partnership_form.save!
    Placements::Partnerships::Notify::Create.call(
      source_organisation: @school,
      partner_organisation: partner_provider,
    )
    flash[:success] = t(".partner_provider_added")
    redirect_to placements_school_partner_providers_path(@school)
  end

  def show; end

  def remove; end

  def destroy
    authorize @partnership

    provider = @partnership.provider
    @partnership.destroy!
    Placements::Partnerships::Notify::Remove.call(
      source_organisation: @school,
      partner_organisation: provider,
    )

    redirect_to placements_school_partner_providers_path(@school),
                flash: { success: t(".partner_provider_removed") }
  end

  private

  def set_school
    @school = current_user.schools.find(params.fetch(:school_id))
  end

  def set_decorated_partner_provider
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
    @partner_provider ||= partnership_form.provider.decorate
  end

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
end
