module Placements
  class EditPotentialPlacementsWizard < AddHostingInterestWizard
    attr_reader :school

    delegate :potential_placement_details, :school_contact, to: :school

    def define_steps
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

    def update_potential_placements
      save_potential_placements_information
    end

    def setup_state
      state["phase"] = potential_placement_details["phase"]
      state["year_group_selection"] = potential_placement_details["year_group_selection"]
      state["year_group_placement_quantity_known"] = if potential_placement_details["year_group_placement_quantity"].present?
                                                       { "quantity_known" => "Yes" }
                                                     else
                                                       { "quantity_known" => "No" }
                                                     end
      state["year_group_placement_quantity"] = potential_placement_details["year_group_placement_quantity"]
      state["secondary_subject_selection"] = potential_placement_details["secondary_subject_selection"]
      state["secondary_placement_quantity_known"] = if potential_placement_details["secondary_placement_quantity"].present?
                                                      { "quantity_known" => "Yes" }
                                                    else
                                                      { "quantity_known" => "No" }
                                                    end
      state["secondary_placement_quantity"] = potential_placement_details["secondary_placement_quantity"]
      state["note_to_providers"] = potential_placement_details["note_to_providers"]
    end

    private

    def appetite
      "interested"
    end
  end
end
