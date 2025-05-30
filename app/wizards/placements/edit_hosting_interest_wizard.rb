module Placements
  class EditHostingInterestWizard < AddHostingInterestWizard
    attr_reader :school, :hosting_interest, :current_user

    def initialize(current_user:, hosting_interest:, school:, params:, state:, current_step: nil)
      @hosting_interest = hosting_interest
      super(current_user:, school:, state:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(AppetiteStep)
      case appetite
      when "actively_looking"
        actively_looking_steps
      when "not_open"
        add_step(ReasonNotHostingStep)
        add_step(AreYouSureStep)
      when "interested"
        interested_steps
      end
    end

    def update_hosting_interest
      raise "Invalid wizard state" unless valid?

      ApplicationRecord.transaction do
        hosting_interest.appetite = appetite
        if steps[:reason_not_hosting].present?
          hosting_interest.reasons_not_hosting = reasons_not_hosting
          other_reason_not_hosting = steps
            .fetch(:reason_not_hosting)
            .other_reason_not_hosting
          hosting_interest.other_reason_not_hosting = (other_reason_not_hosting.presence)
        end

        hosting_interest.save!

        if appetite == "interested"
          save_potential_placements_information
        else
          create_placements
        end
      end
    end

    def setup_state
      state["appetite"] = { "appetite" => hosting_interest.appetite }
      state["reason_not_hosting"] = {
        "reasons_not_hosting" => hosting_interest.reasons_not_hosting,
        "other_reason_not_hosting" => hosting_interest.other_reason_not_hosting,
      }
    end

    private

    def actively_looking_steps
      add_step(MultiPlacementWizard::PhaseStep)
      if phases.include?(::Placements::School::PRIMARY_PHASE)
        year_group_steps
      end

      if phases.include?(::Placements::School::SECONDARY_PHASE)
        secondary_subject_steps
      end
      add_step(CheckYourAnswersStep)
    end

    def interested_steps
      add_step(Interested::PhaseStep)
      if phases.include?(::Placements::School::PRIMARY_PHASE)
        year_group_steps
      end
      if phases.include?(::Placements::School::SECONDARY_PHASE)
        secondary_subject_steps
      end
      add_step(Interested::NoteToProvidersStep)
      add_step(ConfirmStep)
    end
  end
end
