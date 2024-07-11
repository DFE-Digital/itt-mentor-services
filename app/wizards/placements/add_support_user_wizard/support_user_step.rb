class Placements::AddSupportUserWizard::SupportUserStep < Placements::BaseStep
  attribute :first_name
  attribute :last_name
  attribute :email

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, format: { with: Placements::SupportUser::SUPPORT_EMAIL_REGEXP }
  validate :new_support_user

  def new_support_user
    return if Placements::SupportUser.find_by(email:).blank?

    errors.add(:email, :taken)
  end

  def support_user
    @support_user ||= Placements::SupportUser.with_discarded
      .discarded
      .find_or_initialize_by(email:).tap do |user|
        user.assign_attributes(first_name:, last_name:)
      end
  end
end
