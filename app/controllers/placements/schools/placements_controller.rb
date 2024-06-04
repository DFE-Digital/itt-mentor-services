class Placements::Schools::PlacementsController < ApplicationController
  before_action :set_school
  before_action :set_placement, only: %i[show edit_provider edit_mentors update remove destroy]
  before_action :set_decorated_placement, only: %i[show remove]
  before_action :authorize_placement, only: %i[edit_provider edit_mentors update]

  def index
    @pagy, placements = pagy(@school.placements.includes(:subject, :mentors).order("subjects.name"))
    @placements = placements.decorate
  end

  def show; end

  def remove; end

  def edit_provider
    @providers = @school.partner_providers.all
  end

  def edit_mentors
    @mentors = @school.mentors.all
  end

  def update
    if valid_attributes?
      @placement.update!(placement_params)

      redirect_to placements_school_placement_path(@school, @placement), flash: { success: t(".success") }
    else
      @mentors = @school.mentors.all if params[:edit_path] == "edit_mentors"

      render params[:edit_path]
    end
  end

  def destroy
    @placement.destroy!
    redirect_to placements_school_placements_path(@school), flash: { success: t(".placement_deleted") }
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

  def valid_attributes?
    if params[:edit_path] == "edit_provider"
      placement_params[:provider_id].present?
    else # params[:edit_path] == "edit_mentors"
      valid_mentor_ids?(placement_params[:mentor_ids].compact_blank)
    end
  end

  def valid_mentor_ids?(mentor_ids)
    if mentor_ids.include?("not_known")
      params[:placement][:mentor_ids] = []
      return true
    end

    if mentor_ids.present? && mentor_ids.all? { |id| @school.mentors.exists?(id:) }
      true
    else
      @placement.errors.add(:mentor_ids, :invalid)
      false
    end
  end

  def placement_params
    params.require(:placement).permit(:provider_id, mentor_ids: [])
  end

  def authorize_placement
    authorize @placement
  end
end
