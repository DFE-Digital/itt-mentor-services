class Placements::MultiPlacementWizard::PlacementQuantityStep < BaseStep
  validate :valid_quantities

  def valid_quantities
    subjects.each do |subject|
      subject_attribute = subject.name_as_attribute
      subject_quantity = try(subject_attribute)

      errors.add(subject_attribute, :blank, message: "#{subject.name} can't be blank") if subject_quantity.blank?
      errors.add(subject_attribute, :not_an_integer, message: "#{subject.name} must be a whole number") unless (subject_quantity.to_f % 1).zero?
      errors.add(subject_attribute, :greater_than, message: "#{subject.name} must be greater than 0") unless subject_quantity.to_i.positive?
    end
  end

  def subjects
    Subject.none
  end
end
