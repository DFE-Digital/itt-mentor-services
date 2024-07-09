class Placements::AddUserWizard::UserStep < Placements::BaseStep
  attribute :first_name
  attribute :last_name
  attribute :email

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :new_membership

  delegate :organisation, to: :wizard

  def new_membership
    return if membership.valid?

    errors.add(:email, :taken)
  end

  def user
    @user ||= Placements::User.find_or_initialize_by(email:).tap do |user|
      user.assign_attributes(first_name:, last_name:)
    end
  end

  def membership
    @membership ||= user.user_memberships.new(organisation:)
  end
end
