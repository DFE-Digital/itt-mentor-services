module Placements
  class EditHostingInterestWizard < BaseWizard
    attr_reader :school

    def initialize(school:, params:, state:, current_step: nil)
      @school = school
      super(state:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(AppetiteStep)
      if appetite == "not_open"
        not_open_steps
      else
        add_step(SubjectsKnownStep)
        if subjects_known?
          actively_looking_steps
        else
          interested_steps
        end
      end
    end

    private

    def not_open_steps
      add_step(MultiPlacementWizard::ReasonNotHostingStep)
      add_step(MultiPlacementWizard::AreYouSureStep)
    end

    def interested_steps
      add_step(MultiPlacementWizard::SchoolContactStep)
      add_step(MultiPlacementWizard::ConfirmStep)
    end

    def actively_looking_steps
      add_step(PhaseStep)
      if phases.include?(::Placements::School::PRIMARY_PHASE)
        primary_subject_steps
      end

      if phases.include?(::Placements::School::SECONDARY_PHASE)
        secondary_subject_steps
      end

      add_step(CheckYourAnswersStep)
    end
  end
end
