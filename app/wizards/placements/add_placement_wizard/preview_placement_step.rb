class Placements::AddPlacementWizard::PreviewPlacementStep < Placements::BaseStep
  delegate :school, to: :wizard
  delegate :steps, to: :wizard

  def placement
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

    placement
  end
end
