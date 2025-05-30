class Placements::Schools::HostingInterests::AddHostingInterestController < Placements::ApplicationController
  include WizardController

  before_action :set_school
  before_action :set_wizard

  attr_reader :school

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.update_hosting_interest
      school.reload
      if appetite == "actively_looking"
        session["whats_next"] = @wizard.placements_information
      end
      @wizard.reset_state

      redirect_to whats_next_placements_school_hosting_interests_path(@school)
    end
  end

  def whats_next
    @current_navigation = if request.referer.match("hosting_interests\/[a-zA-Z0-9-]*\/edit")
                            :organisation_details
                          else
                            :placements
                          end

    return if appetite == "not_open"

    @placement_details = if appetite == "actively_looking"
                           session["whats_next"]
                         else
                           @school.potential_placement_details
                         end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddHostingInterestWizard.new(
      current_user:,
      school:,
      params:,
      state:,
      current_step:,
    )
  end

  def step_path(step)
    add_hosting_interest_placements_school_hosting_interests_path(state_key:, step:)
  end

  def index_path
    placements_school_placements_path(@school)
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
