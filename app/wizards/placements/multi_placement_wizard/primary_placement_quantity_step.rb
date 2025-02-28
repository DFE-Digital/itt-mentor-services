class Placements::MultiPlacementWizard::PrimaryPlacementQuantityStep < BaseStep
  attribute :subject_quantities, default: {}

  delegate :selected_primary_subject_ids, to: :wizard

  def subjects
    Subject.where(id: selected_primary_subject_ids)
  end
end
