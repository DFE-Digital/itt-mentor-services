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
      add_step(MentorsStep) if school.mentors.present?
      add_step(CheckYourAnswersStep)
    end

    def placement_phase
      steps[:phase]&.phase || school.phase
    end

    def create_placement
      raise "Invalid wizard state" unless valid?

      placement = school.placements.build
      placement.subject = steps[:subject].subject

      if steps[:additional_subjects].present?
        placement.additional_subjects = steps[:additional_subjects].additional_subjects
      end

      if steps[:year_group].present?
        placement.year_group = steps[:year_group].year_group
      end

      if steps[:mentors].present?
        placement.mentors = steps[:mentors].mentors
      end

      placement.save!

      placement
    end
  end
end
