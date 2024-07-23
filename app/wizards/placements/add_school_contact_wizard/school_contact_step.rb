class Placements::AddSchoolContactWizard::SchoolContactStep < Placements::BaseStep
  attribute :first_name
  attribute :last_name
  attribute :email_address

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :only_one_contact_per_school

  delegate :school, to: :wizard

  def only_one_contact_per_school
    another_contact = Placements::SchoolContact.where(school:).excluding(school_contact)
    return unless another_contact.exists?

    errors.add(:email_address, :taken)
  end

  def school_contact
    @school_contact ||= if wizard.respond_to?(:school_contact)
                          wizard.school_contact
                        else
                          school.build_school_contact(first_name:, last_name:, email_address:)
                        end
  end
end
