module Placements
  class AddPlacementWizard < BaseWizard
    attr_reader :school

    def initialize(school:, params:, session:, current_step: nil)
      @school = school
      super(session:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(PhaseStep) unless school.primary_or_secondary_only?
      add_step(SubjectStep)
      add_step(AdditionalSubjectsStep) if steps[:subject].subject_has_child_subjects?
      add_step(YearGroupStep) if placement_phase == School::PRIMARY_PHASE
      # AcademicYearStep goes here
      add_step(TermsStep)
      add_step(MentorsStep) if school.mentors.present?
      add_step(CheckYourAnswersStep)
      add_step(PreviewPlacementStep) if current_step == :preview_placement
    end

    def placement_phase
      steps[:phase]&.phase || school.phase
    end

    def create_placement
      raise "Invalid wizard state" unless valid?

      placement = build_placement

      placement.save!
      placement
    end

    def build_placement
      placement = school.placements.build
      placement.academic_year = ::Placements::AcademicYear.current
      placement.subject = steps[:subject].subject
      placement.terms = steps[:terms].terms

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
  end
end
