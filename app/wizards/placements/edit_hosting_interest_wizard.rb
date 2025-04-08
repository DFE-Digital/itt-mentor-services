module Placements
  class EditHostingInterestWizard < MultiPlacementWizard
    attr_reader :school, :hosting_interest

    def initialize(hosting_interest:, school:, params:, state:, current_step: nil)
      @hosting_interest = hosting_interest
      super(school:, state:, params:, current_step:)
    end

    def update_hosting_interest
      raise "Invalid wizard state" unless valid?

      ApplicationRecord.transaction do
        hosting_interest.appetite = if appetite == "not_open"
                                      "not_open"
                                    elsif subjects_known?
                                      "actively_looking"
                                    else
                                      "interested"
                                    end
        if steps[:reason_not_hosting].present?
          hosting_interest.reasons_not_hosting = reasons_not_hosting
          other_reason_not_hosting = steps
            .fetch(:reason_not_hosting)
            .other_reason_not_hosting
          hosting_interest.other_reason_not_hosting = (other_reason_not_hosting.presence)
        end

        hosting_interest.save!

        create_placements
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

    def not_open_steps
      add_step(MultiPlacementWizard::ReasonNotHostingStep)
      add_step(MultiPlacementWizard::AreYouSureStep)
    end

    def interested_steps
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
