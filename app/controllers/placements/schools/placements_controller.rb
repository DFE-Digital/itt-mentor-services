class Placements::Schools::PlacementsController < ApplicationController
  before_action :set_school
  before_action :set_placement, only: %i[show edit_provider update remove destroy]
  before_action :set_decorated_placement, only: %i[show remove]

  def index
    @pagy, placements = pagy(@school.placements.includes(:subjects, :mentors).order("subjects.name"))
    @placements = placements.decorate
  end

  def show; end

  def remove; end

  def edit_provider
    @providers = Provider.all
  end

  def update
    @placement.provider = provider_params[:provider_name].present? ? Provider.find(provider_params[:provider_id]) : nil

    if @placement.save!
      redirect_to placements_school_placement_path(@school, @placement), flash: { success: t(".success") }
    else
      render :edit_provider
    end
  end

  def destroy
    @placement.destroy!
    redirect_to placements_school_placements_path(@school), flash: { success: t(".placement_removed") }
  end

  private

  def set_placement
    @placement = @school.placements.find(params.require(:id))
  end

  def set_school
    @school = current_user.schools.find(params.require(:school_id))
  end

  def set_decorated_placement
    @placement = @placement.decorate
  end

  def provider_params
    params.require(:provider).permit(:provider_id, :provider_name)
  end
end
