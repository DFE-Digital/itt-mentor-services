class Placements::AddUserWizard::UserStep < Placements::AddUserWizard::BaseStep
  attribute :first_name
  attribute :last_name
  attribute :email

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
