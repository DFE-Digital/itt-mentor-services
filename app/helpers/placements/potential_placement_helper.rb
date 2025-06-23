module Placements::PotentialPlacementHelper
  def potential_placement_details_viewable?(placement_details)
    @potential_placement_details_viewable ||= potential_placement_year_group_selection(placement_details).present? ||
      potential_placement_subject_id_selection(placement_details).present? ||
      potential_placement_key_stage_id_selection(placement_details).present?
  end

  def selected_placement_details(placement_details:, phase:)
    case phase
    when :primary
      if placement_detail_unknown(potential_placement_year_group_selection(placement_details))
        Placements::AddHostingInterestWizard::UNKNOWN_OPTION
      else
        potential_placement_year_group_selection(placement_details)
      end
    when :secondary
      if placement_detail_unknown(potential_placement_subject_id_selection(placement_details))
        Placements::AddHostingInterestWizard::UNKNOWN_OPTION
      else
        Subject.where(id: potential_placement_subject_id_selection(placement_details))
      end
    when :send
      if placement_detail_unknown(potential_placement_key_stage_id_selection(placement_details))
        Placements::AddHostingInterestWizard::UNKNOWN_OPTION
      else
        Placements::KeyStage.where(id: potential_placement_key_stage_id_selection(placement_details))
      end
    else
      []
    end
  end

  def potential_placement_year_group_selection(placement_details)
    @potential_placement_year_group_selection ||= placement_details.dig("year_group_selection", "year_groups")
  end

  def potential_placement_subject_id_selection(placement_details)
    @potential_placement_subject_id_selection ||= placement_details.dig("secondary_subject_selection", "subject_ids")
  end

  def potential_placement_key_stage_id_selection(placement_details)
    @potential_placement_key_stage_id_selection ||= placement_details.dig("key_stage_selection", "key_stage_ids")
  end

  def placement_detail_unknown(value)
    value.include?(Placements::AddHostingInterestWizard::UNKNOWN_OPTION)
  end
end
