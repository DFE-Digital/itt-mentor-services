class Placements::Schools::Placements::BuildController < Placements::ApplicationController
  before_action :setup_session, except: :new
  before_action :authorize_placement

  def new
    reset_session
    setup_skipped_steps
    @placement = build_placement
    handle_primary_or_secondary if school.primary_or_secondary_only?

    redirect_to public_send("#{steps[0]}_placements_school_placement_build_index_path", school_id: school.id)
  end

  def add_phase
    @current_step = Placements::AddPlacementWizard::PhaseStep.new(school:, phase:)
    @previous_step = previous_step(:add_phase)
  end

  def add_subject
    phase_step = Placements::AddPlacementWizard::PhaseStep.new(school:, phase:)
    @current_step = Placements::AddPlacementWizard::SubjectStep.new(school:, phase: phase_step.phase, subject_id:)
    @previous_step = previous_step(:add_subject)
  end

  def add_additional_subjects
    phase_step = Placements::AddPlacementWizard::PhaseStep.new(school:, phase:)
    subject_step = Placements::AddPlacementWizard::SubjectStep.new(school:, phase: phase_step.phase, subject_id:)
    @current_step = Placements::AddPlacementWizard::AdditionalSubjectsStep.new(school:, parent_subject_id: subject_step.subject_id,
                                                                               additional_subject_ids:)
    @previous_step = previous_step(:add_additional_subjects)
  end

  def add_year_group
    @current_step = Placements::AddPlacementWizard::YearGroupStep.new(school:, year_group:)
    @previous_step = previous_step(:add_year_group)
  end

  def add_mentors
    @current_step = Placements::AddPlacementWizard::MentorsStep.new(school:, mentor_ids:)
    @previous_step = previous_step(:add_mentors)
  end

  def check_your_answers
    @placement = initialize_placement.decorate
    @phase = session.dig("add_a_placement", "phase")
    @selected_subject = Subject.find(subject_id)
    @selected_additional_subjects = @selected_subject.child_subjects.where(id: additional_subject_ids)
    @selected_year_group = session.dig("add_a_placement", "year_group") if school.phase == "Primary"
    @selected_mentor_text = if @placement.mentors.empty?
                              t(".not_yet_known")
                            else
                              @placement.mentors.map(&:full_name).to_sentence
                            end
    @previous_step = previous_step(:check_your_answers)
  end

  def update
    case params[:id].to_sym
    when :check_your_answers
      phase_step = Placements::AddPlacementWizard::PhaseStep.new(school:, phase:)
      subject_step = Placements::AddPlacementWizard::SubjectStep.new(school:, phase: phase_step.phase, subject_id:)
      additional_subject_step = Placements::AddPlacementWizard::AdditionalSubjectsStep.new(
        school:,
        parent_subject_id: subject_step.subject_id,
        additional_subject_ids:,
      )
      mentor_step = Placements::AddPlacementWizard::MentorsStep.new(school:, mentor_ids:)
      year_group_step = Placements::AddPlacementWizard::YearGroupStep.new(school:, year_group:)
      @placement = Placements::Schools::Placements::Build::Placement.new(school:, phase: phase_step.phase)

      @placement.assign_attributes [mentor_step.wizard_attributes,
                                    year_group_step.wizard_attributes,
                                    subject_step.wizard_attributes].inject(:merge)
      if subject_step.subject_has_child_subjects?
        @placement.additional_subject_ids = additional_subject_step.additional_subject_ids
      end
      @placement.build_mentors(mentor_step.wizard_attributes[:mentor_ids])
      @placement.save!

      Placements::PlacementSlackNotifier.placement_created_notification(school, @placement.decorate).deliver_later

      session.delete("add_a_placement")
      redirect_to placements_school_placements_path(school), flash: { success: t(".success") } and return
    when :add_phase
      @current_step = Placements::AddPlacementWizard::PhaseStep.new(school:, phase: phase_params)

      if @current_step.valid?
        session["add_a_placement"]["skipped_steps"] << "add_year_group" unless @current_step.phase == "Primary"
        session["add_a_placement"]["phase"] = @current_step.phase
      else
        render :add_phase and return
      end
    when :add_subject
      phase_step = Placements::AddPlacementWizard::PhaseStep.new(school:, phase:)
      @current_step = Placements::AddPlacementWizard::SubjectStep.new(school:, phase: phase_step.phase, subject_id: subject_params)

      if @current_step.valid?
        if @current_step.subject_has_child_subjects?
          session["add_a_placement"]["skipped_steps"].delete("add_additional_subjects")
        else
          session["add_a_placement"]["additional_subject_ids"] = []
          session["add_a_placement"]["skipped_steps"] << "add_additional_subjects"
        end
        session["add_a_placement"]["subject_id"] = @current_step.subject_id
      else
        render :add_subject and return
      end
    when :add_additional_subjects
      phase_step = Placements::AddPlacementWizard::PhaseStep.new(school:, phase:)
      subject_step = Placements::AddPlacementWizard::SubjectStep.new(school:, phase: phase_step.phase, subject_id:)
      @current_step = Placements::AddPlacementWizard::AdditionalSubjectsStep.new(school:,
                                                                                 parent_subject_id: subject_step.subject_id,
                                                                                 additional_subject_ids: additional_subject_ids_params)

      if @current_step.valid?
        session["add_a_placement"]["additional_subject_ids"] = @current_step.additional_subject_ids
      else
        render :add_additional_subjects and return
      end
    when :add_year_group
      @current_step = Placements::AddPlacementWizard::YearGroupStep.new(school:, year_group: year_group_params)

      if @current_step.valid?
        session["add_a_placement"]["year_group"] = @current_step.year_group
      else
        render :add_year_group and return
      end
    when :add_mentors
      @current_step = Placements::AddPlacementWizard::MentorsStep.new(school:, mentor_ids: mentor_ids_params)

      if @current_step.valid?
        session["add_a_placement"]["mentor_ids"] = @current_step.mentor_ids
      else
        render :add_mentors and return
      end
    else
      redirect_to placements_school_placements_path(school),
                  flash: { alert: t("errors.internal_server_error.page_title") } and return
    end

    redirect_to next_step(params[:id])
  end

  private

  STEPS = %i[add_phase add_subject add_additional_subjects add_year_group add_mentors check_your_answers].freeze

  def reset_session
    session.delete("add_a_placement")
    setup_session
  end

  def handle_primary_or_secondary
    session["add_a_placement"]["placement"] = @placement.attributes
    session["add_a_placement"]["phase"] = school.phase
  end

  def setup_session
    session["add_a_placement"] = {} if session["add_a_placement"].blank?
  end

  def initialize_placement
    subject = Subject.find(subject_id)
    year_group = session.dig("add_a_placement", "year_group")
    placement = Placements::Schools::Placements::Build::Placement.new(school:, subject:, year_group:)
    placement.build_mentors(mentor_ids || [])
    placement.additional_subject_ids = additional_subject_ids
    placement
  end

  def steps
    if skipped_steps.present?
      STEPS - skipped_steps.map(&:to_sym)
    else
      STEPS
    end
  end

  def next_step(step)
    public_send("#{steps[steps.index(step.to_sym) + 1]}_placements_school_placement_build_index_path")
  end

  def previous_step(step)
    return placements_school_placements_path(school) if steps.index(step.to_sym).zero?

    public_send("#{steps[steps.index(step.to_sym) - 1]}_placements_school_placement_build_index_path")
  end

  def school
    @school ||= current_user.schools.find(params.require(:school_id))
  end

  def build_placement
    if session.dig("add_a_placement", "phase").present?
      Placements::Schools::Placements::Build::Placement.new(school:,
                                                            phase: session.dig("add_a_placement", "phase"))
    else
      Placements::Schools::Placements::Build::Placement.new(school:)
    end
  end

  def setup_skipped_steps
    session["add_a_placement"]["skipped_steps"] = []
    session["add_a_placement"]["skipped_steps"] << "add_phase" if school.primary_or_secondary_only?
    session["add_a_placement"]["skipped_steps"] << "add_mentors" unless school.mentors.exists?
    session["add_a_placement"]["skipped_steps"] << "add_year_group" if school.phase == "Secondary"
  end

  def skipped_steps
    session.dig("add_a_placement", "skipped_steps") || []
  end

  def year_groups_for_select
    @year_groups_for_select ||= Placement.year_groups_as_options
  end

  def additional_subject_ids
    @additional_subject_ids ||= session.dig("add_a_placement", "additional_subject_ids")
  end

  def phase
    @phase ||= session.dig("add_a_placement", "phase") || school.phase
  end

  def subject_id
    @subject_id ||= session.dig("add_a_placement", "subject_id")
  end

  def mentor_ids
    @mentor_ids ||= session.dig("add_a_placement", "mentor_ids")&.compact_blank
  end

  def year_group
    @year_group ||= session.dig("add_a_placement", "year_group")
  end

  def phase_params
    params.dig(:placements_add_placement_wizard_phase_step, :phase)
  end

  def subject_params
    params.dig(:placements_add_placement_wizard_subject_step, :subject_id)
  end

  def additional_subject_ids_params
    params.dig(:placements_add_placement_wizard_additional_subjects_step, :additional_subject_ids).compact_blank
  end

  def mentor_ids_params
    params.dig(:placements_add_placement_wizard_mentors_step, :mentor_ids).compact_blank
  end

  def year_group_params
    params.dig(:placements_add_placement_wizard_year_group_step, :year_group)
  end

  def authorize_placement
    authorize Placement.new(school:)
  end
end
