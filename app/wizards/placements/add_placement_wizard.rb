module Placements
  class AddPlacementWizard < BaseWizard
    attr_reader :school

    def initialize(school:, params:, state:, current_step: nil)
      @school = school
      super(state:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(PhaseStep) unless school.primary_or_secondary_only?
      case placement_phase
      when School::PRIMARY_PHASE
        primary_steps
      when School::SECONDARY_PHASE
        secondary_steps
      end
      add_step(AcademicYearStep)
      add_step(TermsStep)
      add_step(MentorsStep) if school.mentors.present?
      add_step(CheckYourAnswersStep)
      add_step(PreviewPlacementStep) if current_step == :preview_placement
    end

    def placement_phase
      steps[:phase]&.phase || school.phase
    end

    def subject
      case placement_phase
      when School::PRIMARY_PHASE
        Subject.primary_subject
      when School::SECONDARY_PHASE
        steps.fetch(:secondary_subject_selection).subject
      end
    end

    def create_placement
      raise "Invalid wizard state" unless valid?

      placement = build_placement

      placement.save!
      placement
    end

    def build_placement
      placement = school.placements.build
      placement.academic_year = steps.fetch(:academic_year).academic_year
      placement.subject = subject
      placement.terms = steps.fetch(:terms).terms

      if steps[:additional_subjects].present?
        placement.additional_subjects = steps[:additional_subjects].additional_subjects
      end

      if steps[:year_group].present?
        placement.year_group = steps[:year_group].year_group
      end

      if steps[:mentors].present?
        placement.mentors = steps[:mentors].mentors
      end

      placement
    end

    def primary_steps
      add_step(YearGroupStep)
    end

    def secondary_steps
      add_step(SecondarySubjectSelectionStep)
      add_step(AdditionalSubjectsStep) if steps.fetch(:secondary_subject_selection).subject_has_child_subjects?
    end
  end
end
