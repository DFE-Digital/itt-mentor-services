class Placements::MultiPlacementWizard::SchoolContactStep < Placements::AddSchoolContactWizard::SchoolContactStep
  delegate :appetite, to: :wizard

  def school_contact
    @school_contact ||= wizard.school_contact.presence || school.build_school_contact(first_name:, last_name:, email_address:)
  end
end
