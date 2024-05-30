class Placements::Schools::Placements::BuildController < ApplicationController
  before_action :setup_session, except: :new
  before_action :authorize_placement

  def new
    reset_session
    setup_skipped_steps
    @placement = build_placement
    school.primary_or_secondary_only? ? handle_primary_or_secondary : handle_other
  end

  def add_phase
    @placement = build_placement
    @selected_phase = session.dig(:add_a_placement, "phase") || school.phase
  end

  def add_subject
    @placement = build_placement
    assign_subjects_based_on_phase
    @selected_subject_id = session.dig(:add_a_placement, "subject_id")
  end

  def add_additional_subjects
    @placement = build_or_retrieve_placement
    @selected_subject = Subject.find(session.dig(:add_a_placement, "subject_id"))
    @additional_subjects = assign_additional_subjects
    @selected_additional_subjects = @placement.additional_subjects
  end

  def add_year_group
    @placement = build_placement
    @year_groups = Placements::Schools::Placements::Build::Placement.year_groups.map do |value, name|
      OpenStruct.new value:, name:, description: t("placements.schools.placements.year_groups.#{value}_description")
    end
    @placement.year_group = session.dig(:add_a_placement, "year_group")
  end

  def add_mentors
    @placement = build_placement
    @selected_mentors = retrieve_selected_mentors
  end

  def check_your_answers
    @placement = initialize_placement.decorate
    @phase = session.dig(:add_a_placement, "phase")
    @selected_subject = Subject.find(session.dig(:add_a_placement, "subject_id"))
    @selected_additional_subjects = @selected_subject.child_subjects.where(id: additional_subject_ids)
    @selected_year_group = session.dig(:add_a_placement, "year_group") if school.phase == "Primary"
    @selected_mentor_text = if @placement.mentors.empty?
                              t(".not_yet_known")
                            else
                              @placement.mentors.map(&:full_name).to_sentence
                            end
  end

  def update
    case params[:id].to_sym
    when :check_your_answers
      subject = Subject.find(session.dig(:add_a_placement, "subject_id"))
      phase = session.dig(:add_a_placement, "phase")
      @placement = Placements::Schools::Placements::Build::Placement.new(school:, phase:, subject:)
      @placement.mentor_ids = mentor_ids
      if subject.has_child_subjects?
        @placement.additional_subject_ids = additional_subject_ids
        @placement.build_additional_subjects(additional_subject_ids)
      end
      @placement.year_group = session.dig(:add_a_placement, "year_group") if school.phase == "Primary"
      @placement.build_mentors(mentor_ids)
      @placement.save!

      session.delete(:add_a_placement)
      redirect_to placements_school_placements_path(school), flash: { success: t(".success") } and return
    when :add_phase
      @placement = build_placement
      @placement.phase = phase_params

      if @placement.valid_phase?
        session[:add_a_placement]["skipped_steps"] << "add_year_group" if @placement.phase != "Primary"
        session[:add_a_placement][:phase] = phase_params
      else
        render :add_phase and return
      end
    when :add_subject
      subject_id = subject_params
      @placement = build_placement
      @placement.subject = Subject.find(subject_id) if subject_id.present?

      if @placement.subject_has_child_subjects?
        session[:add_a_placement]["skipped_steps"].delete("add_additional_subjects")
      else
        session[:add_a_placement][:additional_subject_ids] = []
        session[:add_a_placement]["skipped_steps"] << "add_additional_subjects"
      end

      if @placement.valid_subject?
        session[:add_a_placement][:subject_id] = subject_id
      else
        assign_subjects_based_on_phase
        render :add_subject and return
      end
    when :add_additional_subjects
      additional_subject_ids = additional_subject_ids_params
      @placement = build_placement
      @placement.additional_subject_ids = additional_subject_ids if additional_subject_ids.present?

      if @placement.valid_additional_subjects?
        session[:add_a_placement][:additional_subject_ids] = additional_subject_ids
      else
        @selected_subject = Subject.find(session.dig(:add_a_placement, "subject_id"))
        assign_additional_subjects
        render :add_additional_subjects and return
      end
    when :add_year_group
      year_group = params.dig(:placements_schools_placements_build_placement, :year_group)
      @placement = build_placement
      @placement.year_group = year_group

      if @placement.valid_year_group?
        session[:add_a_placement][:year_group] = year_group
      else
        @year_groups = Placements::Schools::Placements::Build::Placement.year_groups.map do |value, name|
          OpenStruct.new value:, name:, description: t("placements.schools.placements.year_groups.#{value}_description")
        end
        render :add_year_group and return
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
                  flash: { alert: t("errors.internal_server_error.page_title") } and return
    end

    redirect_to public_send(next_step(params[:id]))
  end

  private

  STEPS = %i[add_phase add_subject add_additional_subjects add_year_group add_mentors check_your_answers].freeze

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

  def build_or_retrieve_placement
    @placement = build_placement
    @placement.build_additional_subjects(additional_subject_ids)
    @placement
  end

  def assign_subjects_based_on_phase
    phase = session.dig(:add_a_placement, "phase")
    @phase = @placement.build_phase(phase)
    @subjects = @phase == "Primary" ? Subject.parent_subjects.primary : Subject.parent_subjects.secondary
  end

  def assign_additional_subjects
    @additional_subjects = @selected_subject.child_subjects
  end

  def retrieve_selected_mentors
    mentor_ids = session.dig(:add_a_placement, "mentor_ids")&.compact_blank
    return [] if mentor_ids.blank?

    return [:not_known] if mentor_ids.include?("not_known")

    school.mentors.where(id: mentor_ids)
  end

  def initialize_placement
    subject = Subject.find(session.dig(:add_a_placement, "subject_id"))
    year_group = session.dig(:add_a_placement, "year_group")
    placement = Placements::Schools::Placements::Build::Placement.new(school:, subject:, year_group:)
    placement.build_mentors(mentor_ids)
    placement.build_additional_subjects(additional_subject_ids)
    placement
  end

  def next_step(step)
    steps = if skipped_steps.present?
              STEPS - skipped_steps.map(&:to_sym)
            else
              STEPS
            end

    "#{steps[steps.index(step.to_sym) + 1]}_placements_school_placement_build_index_path"
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

  def setup_skipped_steps
    session[:add_a_placement][:skipped_steps] = []
    session[:add_a_placement][:skipped_steps] << "add_mentors" unless school.mentors.exists?
    session[:add_a_placement][:skipped_steps] << "add_year_group" if school.phase == "Secondary"
  end

  def skipped_steps
    session.dig(:add_a_placement, "skipped_steps") || []
  end

  def additional_subject_ids
    @additional_subject_ids ||= session.dig(:add_a_placement, "additional_subject_ids")
  end

  def mentor_ids
    @mentor_ids ||= session.dig(:add_a_placement, "mentor_ids") || %w[not_known]
  end

  def phase_params
    params.dig(:placements_schools_placements_build_placement, :phase)
  end

  def subject_params
    params.dig(:placements_schools_placements_build_placement, :subject_id)
  end

  def additional_subject_ids_params
    params.dig(:placements_schools_placements_build_placement, :additional_subject_ids).compact_blank
  end

  def mentor_ids_params
    params.dig(:placements_schools_placements_build_placement, :mentor_ids).compact_blank
  end

  def authorize_placement
    authorize Placement.new(school:)
  end
end
