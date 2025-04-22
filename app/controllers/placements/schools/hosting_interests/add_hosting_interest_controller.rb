class Placements::Schools::HostingInterests::AddHostingInterestController < Placements::ApplicationController
  include WizardController

  before_action :set_school
  before_action :set_wizard
  before_action :authorize_placement

  attr_reader :school

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
    @current_navigation = if request.referer.match("hosting_interests\/[a-zA-Z0-9-]*\/edit")
                            :organisation_details
                          else
                            :placements
                          end
    appetite
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddHostingInterestWizard.new(school:, params:, state:, current_step:)
  end

  def authorize_placement
    authorize school.placements.build, :bulk_add_placements?
  end

  def step_path(step)
    add_hosting_interest_placements_school_hosting_interests_path(state_key:, step:)
  end

  def index_path
    placements_school_placements_path(@school)
  end

  def success_path
    if appetite == "actively_looking"
      placements_school_placements_path(@school)
    else
      whats_next_placements_school_hosting_interests_path(@school)
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
