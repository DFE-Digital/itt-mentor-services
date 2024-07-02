class Placements::PartnershipsController < Placements::ApplicationController
  before_action :set_organisation
  before_action :set_decorated_partner_organisation, only: %i[show remove destroy]
  before_action :set_partnership, only: %i[show remove destroy]

  def new
    @partnership_form = if params[:partnership].present?
                          partnership_form
                        else
                          new_partnership_form
                        end
  end

  def check
    if partnership_form.valid?
      partner_organisation
      back_link
    else
      render :new
    end
  end

  def create
    partnership_form.save!
    Placements::Partnerships::Notify::Create.call(
      source_organisation:,
      partner_organisation:,
    )
    redirect_to_index_path
  end

  def show; end

  def remove; end

  def destroy
    authorize @partnership

    @partnership.destroy!
    Placements::Partnerships::Notify::Remove.call(
      source_organisation:,
      partner_organisation:,
    )

    redirect_to_index_path
  end

  private

  def check_partner_organisation_options
    if partnership_form(javascript_disabled: true).valid?
      redirect_to_check_path
    else
      render_partner_organisation_options
    end
  end
end
