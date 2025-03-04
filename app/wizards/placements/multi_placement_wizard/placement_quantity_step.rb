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

  def assigned_variables
    subjects.map { |attribute|
      { attribute.name_as_attribute.to_s => instance_variable_get("@#{attribute.name_as_attribute}") }
    }.reduce({}, :merge)
  end

  def subjects
    Subject.none
  end

  private

  def define_subject_attributes(selected_subjects:, attributes:)
    selected_subjects.each do |subject|
      singleton_class.class_eval { attr_accessor subject.name_as_attribute }
      instance_variable_set(
        "@#{subject.name_as_attribute}",
        attributes.blank? ? nil : attributes[subject.name_as_attribute.to_s],
      )
    end
  end
end
