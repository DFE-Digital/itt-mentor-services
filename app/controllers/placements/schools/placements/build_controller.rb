class Placements::Schools::Placements::BuildController < ApplicationController
  before_action :setup_session, except: :new

  def new
    reset_session
    @placement = build_placement
    school.primary_or_secondary_only? ? handle_primary_or_secondary : handle_other
  end

  def add_phase
    @placement = build_placement
    @selected_phase = session.dig(:add_a_placement, "phase") || school.phase
  end

  def add_subject
    setup_phase_navigation
    build_or_retrieve_placement
    assign_subjects_based_on_phase
  end

  def add_mentors
    @placement = build_placement
    @selected_mentors = find_mentors
  end

  def check_your_answers
    session[:add_a_placement][:enable_phase_navigation] = true
    @placement = initialize_placement
    @phase = session[:add_a_placement]["phase"]
  end

  def update
    case params[:id].to_sym
    when :check_your_answers
      @placement = Placements::Schools::Placements::Build::Placement.new(school:, phase: session.dig(:add_a_placement, "phase"), status: :published)
      @placement.mentor_ids = mentor_ids
      @placement.subject_ids = subject_ids
      @placement.build_subjects(subject_ids)
      @placement.build_mentors(mentor_ids)
      @placement.save!

      session.delete(:add_a_placement)
      redirect_to placements_school_placements_path(school), flash: { success: t(".success") } and return
    when :add_phase
      @placement = build_placement
      @placement.phase = phase_params

      if @placement.valid_phase?
        session[:add_a_placement][:phase] = phase_params
      else
        render :add_phase and return
      end
    when :add_subject
      subject_ids = subject_ids_params
      subject_ids.compact_blank! if subject_ids.instance_of?(Array)
      @placement = build_placement
      @placement.subject_ids = subject_ids if subject_ids.present?

      if @placement.valid_subjects?
        session[:add_a_placement][:subject_ids] = subject_ids
      else
        assign_subjects_based_on_phase
        render :add_subject and return
      end
    when :add_mentors
      mentor_ids = mentor_ids_params
      @placement = build_placement
      @placement.mentor_ids = mentor_ids if mentor_ids.present?

      if @placement.valid_mentor_ids?
        session[:add_a_placement][:mentor_ids] = mentor_ids
      else
        render :add_mentors and return
      end
    else
      redirect_to placements_school_placements_path(school),
                  flash: { error: t("errors.internal_server_error.page_title") } and return
    end

    redirect_to public_send(next_step(params[:id]))
  end

  private

  STEPS = %i[add_phase add_subject add_mentors check_your_answers].freeze

  def reset_session
    session.delete(:add_a_placement)
    setup_session
  end

  def handle_primary_or_secondary
    session[:add_a_placement][:placement] = @placement.attributes
    session[:add_a_placement][:phase] = school.phase
    redirect_to add_subject_placements_school_placement_build_index_path(school_id: school.id)
  end

  def handle_other
    redirect_to add_phase_placements_school_placement_build_index_path(school_id: school.id)
  end

  def setup_session
    session[:add_a_placement] = {} if session[:add_a_placement].blank?
  end

  def setup_phase_navigation
    @enable_phase_navigation = session.dig(:add_a_placement, "enable_phase_navigation")
  end

  def build_or_retrieve_placement
    @placement = build_placement
    @placement.build_subjects(subject_ids)
  end

  def assign_subjects_based_on_phase
    phase = session.dig(:add_a_placement, "phase")
    @phase = @placement.build_phase(phase)
    @subjects = @phase == "Primary" ? Subject.primary : Subject.secondary
    @placement.build_subjects(subject_ids)
    @selected_subjects = @placement.subjects
  end

  def find_mentors
    if session.dig(:add_a_placement, "mentor_ids").present?
      school.mentors.find(session.dig(:add_a_placement, "mentor_ids").compact_blank)
    else
      []
    end
  end

  def initialize_placement
    placement = Placements::Schools::Placements::Build::Placement.new(school:, status: :draft)
    placement.build_mentors(mentor_ids)
    placement.build_subjects(subject_ids)
    placement
  end

  def next_step(step)
    "#{STEPS[STEPS.index(step.to_sym) + 1]}_placements_school_placement_build_index_path"
  end

  def school
    @school ||= current_user.schools.find(params.require(:school_id))
  end

  def build_placement
    if session.dig(:add_a_placement, "phase").present?
      Placements::Schools::Placements::Build::Placement.new(school:,
                                                            phase: session.dig(:add_a_placement, "phase"))
    else
      Placements::Schools::Placements::Build::Placement.new(school:)
    end
  end

  def subject_ids
    @subject_ids ||= session.dig(:add_a_placement, "subject_ids")
  end

  def mentor_ids
    @mentor_ids ||= session.dig(:add_a_placement, "mentor_ids")
  end

  def phase_params
    params.dig(:placements_schools_placements_build_placement, :phase)
  end

  def subject_ids_params
    params.dig(:placements_schools_placements_build_placement, :subject_ids)
  end

  def mentor_ids_params
    params.dig(:placements_schools_placements_build_placement, :mentor_ids).compact_blank
  end
end
