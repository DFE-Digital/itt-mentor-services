class Claims::AddSchoolWizard::SchoolSelectionStep < BaseStep
  attribute :id

  validate :id_presence
  validate :school_already_onboarded?

  def school_name
    @school_name ||= school&.name
  end

  def school_already_onboarded?
    return if school.blank? || !school.claims_service?

    errors.add(
      :id,
      :already_added,
      school_name: school.name,
    )
  end

  def school
    @school ||= School.find_by(id:)
  end

  def scope
    wizard_name = class_to_path(wizard.class)
    step_name = class_to_path(self.class)
    "claims_#{wizard_name}_#{step_name}"
  end

  private

  def class_to_path(klass)
    klass.name.demodulize.underscore
  end
end
