class Placements::PartnershipsController < Placements::ApplicationController
  before_action :set_organisation
  before_action :set_decorated_partner_organisation, only: %i[show remove destroy]
  before_action :set_partnership, only: %i[show remove destroy]

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
end
