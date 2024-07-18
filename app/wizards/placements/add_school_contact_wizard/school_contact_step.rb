class Placements::AddSchoolContactWizard::SchoolContactStep < Placements::BaseStep
  attribute :first_name
  attribute :last_name
  attribute :email_address

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :new_school_contact

  delegate :school, to: :wizard

  def new_school_contact
    return if wizard.is_a?(Placements::EditSchoolContactWizard)

    return unless Placements::SchoolContact.where(
      school:,
    ).exists?

    errors.add(:email_address, :taken)
  end

  def school_contact
    school.build_school_contact(first_name:, last_name:, email_address:)
  end
end
