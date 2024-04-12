class Placements::Schools::Placements::BuildController < ApplicationController
  before_action :setup_session, except: :new

  def new
    reset_session
    @placement = build_placement
    school.primary_or_secondary_only? ? handle_primary_or_secondary : handle_other
  end

  def add_phase
    @placement = build_placement
    @selected_phase = session[:add_a_placement]["phase"] || school.phase
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
      @placement = Placements::Schools::Placements::Build::Placement.new(school:, phase: session[:add_a_placement]["phase"], status: :published)
      @placement.mentor_ids = session[:add_a_placement]["mentor_ids"]
      @placement.subject_ids = session[:add_a_placement]["subject_ids"]
      build_subjects(@placement)
      build_mentors(@placement)

      if @placement.all_valid?
        @placement.save!

        session.delete(:add_a_placement)
        redirect_to placements_school_placements_path(school), flash: { success: t(".success") } and return
      else
        render :check_your_answers and return
      end
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
      raise ActionController::RoutingError, "Not Found"
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
    session.dig(:add_a_placement, "subject_ids").present? ? build_subjects : @placement.subjects.build
  end

  def assign_subjects_based_on_phase
    @phase = session.dig(:add_a_placement, "phase").presence || (school.primary_or_secondary_only? ? school.phase : "Primary")
    @subjects = @phase == "Primary" ? Subject.primary : Subject.secondary
    @selected_subjects = find_subjects
  end

  def find_mentors
    session[:add_a_placement]["mentor_ids"].present? ? school.mentors.find(session.dig(:add_a_placement, "mentor_ids").compact_blank) : []
  end

  def find_subjects
    subject_ids = session.dig(:add_a_placement, "subject_ids")
    if subject_ids.instance_of?(String)
      subject_ids.present? ? [Subject.find(subject_ids)] : []
    else
      subject_ids.present? ? Subject.find(subject_ids.compact_blank) : []
    end
  end

  def initialize_placement
    placement = Placements::Schools::Placements::Build::Placement.new(school:, status: :draft)
    build_mentors(placement)
    build_subjects(placement)
    placement
  end

  def build_mentors(placement = nil)
    placement ||= @placement
    session[:add_a_placement]["mentor_ids"].compact_blank.each do |mentor_id|
      placement.mentors << Placements::Mentor.find(mentor_id)
    end
  end

  def build_subjects(placement = nil)
    placement ||= @placement
    subject_ids = session.dig(:add_a_placement, "subject_ids")
    if subject_ids.instance_of?(String)
      placement.subjects << Subject.find(subject_ids)
    elsif subject_ids.present?
      subject_ids.each do |subject_id|
        placement.subjects << Subject.find(subject_id)
      end
    end
  end

  def next_step(step)
    "#{STEPS[STEPS.index(step.to_sym) + 1]}_placements_school_placement_build_index_path"
  end

  def school
    @school ||= current_user.schools.find(params.require(:school_id))
  end

  def build_placement
    if session.dig(:add_a_placement, "phase").present?
      Placements::Schools::Placements::Build::Placement.new(school:, phase: session.dig(:add_a_placement, "phase"))
    else
      Placements::Schools::Placements::Build::Placement.new(school:)
    end
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
