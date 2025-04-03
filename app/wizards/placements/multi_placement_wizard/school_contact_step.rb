class Placements::MultiPlacementWizard::SchoolContactStep < Placements::AddSchoolContactWizard::SchoolContactStep
  delegate :appetite, :subjects_known?, to: :wizard

  def school_contact
    @school_contact ||= wizard.school_contact.presence || school.build_school_contact(first_name:, last_name:, email_address:)
  end

  def title
    if appetite == "not_open"
      I18n.t(".#{locale_path}.not_open.title")
    elsif subjects_known?
      I18n.t(".#{locale_path}.subjects_known.title")
    else
      I18n.t(".#{locale_path}.subjects_not_known.title")
    end
  end

  private

  def locale_path
    ".wizards.placements.multi_placement_wizard.school_contact_step"
  end
end
