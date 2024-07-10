class Placements::Support::Schools::PlacementsController < Placements::ApplicationController
  before_action :set_school
  before_action :set_placement, except: %i[index]

  helper_method :edit_attribute_path, :add_provider_path, :add_mentor_path

  def index
    @pagy, placements = pagy(@school.placements.includes(:subject, :mentors).order("subjects.name"))
    @placements = placements.decorate
  end

  def show; end

  def remove; end

  def destroy
    @placement.destroy!
    redirect_to placements_support_school_placements_path(@school), flash: { success: t(".placement_removed") }
  end

  private

  def set_school
    @school = Placements::School.find(params.fetch(:school_id))
  end

  def set_placement
    @placement = @school.placements.find(params.fetch(:id)).decorate
  end

  def edit_attribute_path(attribute)
    new_edit_placement_placements_support_school_placement_path(@school, @placement, step: attribute)
  end

  def add_provider_path
    placements_support_school_partner_providers_path
  end

  def add_mentor_path
    placements_support_school_mentors_path
  end
end
