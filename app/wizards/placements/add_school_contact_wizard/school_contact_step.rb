class Placements::AddSchoolContactWizard::SchoolContactStep < Placements::BaseStep
  attribute :first_name
  attribute :last_name
  attribute :email_address

  validates :first_name, :last_name, presence: true
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :new_school_contact

  delegate :school, to: :wizard

  def new_school_contact
    return if Placements::SchoolContact.find_by(
      school_id: school.id,
    ).blank?

    errors.add(:email_address, :taken)
  end

  def school_contact
    school.build_school_contact(first_name:, last_name:, email_address:)
  end
end
