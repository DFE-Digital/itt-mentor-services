class UserInviteForm
  FORM_PARAMS = %i[first_name last_name email].freeze
  include ActiveModel::Model

  attr_accessor :email, :first_name, :last_name, :service, :organisation

  validate :validate_user
  validate :validate_membership
  validates :service, :organisation, presence: true

  def invite
    return false unless valid?

    UserInviteService.call(user, organisation) if save_user
  end

  def as_form_params
    { "user_invite_form" => slice(FORM_PARAMS) }
  end

  private

  def user
    @user ||=
      begin
        user = user_klass.find_or_initialize_by(email:)
        user.assign_attributes(first_name:, last_name:)
        user
      end
  end

  def save_user
    ActiveRecord::Base.transaction do
      user.save!
      membership.save!
    end
  end

  def validate_user
    if user.invalid?
      user.errors.each do |err|
        errors.add(err.attribute, err.message)
      end
    end
  end

  def validate_membership
    if membership.invalid?
      errors.add(:email, :taken)
    end
  end

  def membership
    @membership ||= user.memberships.new(organisation:)
  end

  def user_klass
    { claims: Claims::User,
      placements: Placements::User }.fetch service
  end
end
