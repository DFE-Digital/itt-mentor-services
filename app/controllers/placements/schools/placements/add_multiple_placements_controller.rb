class Placements::Schools::Placements::AddMultiplePlacementsController < Placements::ApplicationController
  include WizardController

  before_action :set_school
  before_action :set_wizard
  before_action :authorize_placement

  attr_reader :school

  # This only lives here as part of the concept testing
  def concept_index
    @pagy, placements = pagy(
      school
        .placements
        .includes(:subject, :mentors, :additional_subjects, :provider)
        .order("subjects.name"),
    )
    @placements = placements.decorate
  end

  def new
    @wizard.setup_state
    redirect_to step_path(@wizard.first_step)
  end

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.update_school_placements
      @wizard.reset_state
      school.reload

      redirect_to success_path, flash: {
        heading: t(".heading.#{appetite}"),
        body: t(".body.#{appetite}_html"),
      }
    end
  end

  def whats_next
    appetite
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::MultiPlacementWizard.new(school:, params:, state:, current_step:)
  end

  def authorize_placement
    authorize school.placements.build, :bulk_add_placements?
  end

  def step_path(step)
    add_multiple_placements_placements_school_placements_path(state_key:, step:)
  end

  def index_path
    placements_school_placements_path(@school)
  end

  def success_path
    if appetite == "actively_looking"
      concept_index_placements_school_placements_path(@school)
    else
      whats_next_placements_school_placements_path(@school)
    end
  end

  def appetite
    @appetite ||= next_academic_year_hosting_interest.appetite
  end

  def next_academic_year_hosting_interest
    @next_academic_year_hosting_interest ||= school
      .reload
      .hosting_interests
      .for_academic_year(Placements::AcademicYear.current.next)
      .last
  end
end
