module Placements
  class EditPotentialPlacementsWizard < AddHostingInterestWizard
    attr_reader :school

    delegate :potential_placement_details, :school_contact, to: :school

    def define_steps
      setup_state if state.blank?
      add_step(Interested::PhaseStep)
      if primary_phase?
        year_group_steps
      end

      if secondary_phase?
        secondary_subject_steps
      end

      if send_specific?
        send_steps
      end

      add_step(Interested::NoteToProvidersStep)
      add_step(ConfirmStep)
    end

    def update_potential_placements
      save_potential_placements_information
    end

    def setup_state
      state["phase"] = potential_placement_details["phase"]
      # Primary placement steps
      state["year_group_selection"] = potential_placement_details["year_group_selection"]
      state["year_group_placement_quantity_known"] = if potential_placement_details["year_group_placement_quantity"].present?
                                                       { "quantity_known" => "Yes" }
                                                     else
                                                       { "quantity_known" => "No" }
                                                     end
      if potential_placement_details["year_group_placement_quantity"].present?
        state["year_group_placement_quantity"] = potential_placement_details["year_group_placement_quantity"]
      end
      # Secondary placement steps
      state["secondary_subject_selection"] = potential_placement_details["secondary_subject_selection"]
      state["secondary_placement_quantity_known"] = if potential_placement_details["secondary_placement_quantity"].present?
                                                      { "quantity_known" => "Yes" }
                                                    else
                                                      { "quantity_known" => "No" }
                                                    end
      if potential_placement_details["secondary_placement_quantity"].present?
        state["secondary_placement_quantity"] = potential_placement_details["secondary_placement_quantity"]
      end
      # SEND
      state["key_stage_selection"] = potential_placement_details["key_stage_selection"]
      state["key_stage_placement_quantity_known"] = if potential_placement_details["key_stage_placement_quantity"].present?
                                                      { "quantity_known" => "Yes" }
                                                    else
                                                      { "quantity_known" => "No" }
                                                    end
      if potential_placement_details["key_stage_placement_quantity"].present?
        state["key_stage_placement_quantity"] = potential_placement_details["key_stage_placement_quantity"]
      end

      state["note_to_providers"] = potential_placement_details["note_to_providers"]
    end

    private

    def appetite
      "interested"
    end
  end
end
