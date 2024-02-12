class SupportUserInviteForm < ApplicationForm
  FORM_PARAMS = %i[first_name last_name email].freeze

  attr_accessor :email, :first_name, :last_name, :service

  validate :validate_support_user
  validates :service, presence: true

  def persist
    save_support_user
  end

  def as_form_params
    { "support_user" => slice(FORM_PARAMS) }
  end

  def support_user
    @support_user ||=
      begin
        user = user_klass
          .with_discarded
          .discarded
          .find_or_initialize_by(email:)
        user.assign_attributes(first_name:, last_name:)
        user
      end
  end

  private

  def save_support_user
    ActiveRecord::Base.transaction do
      support_user.undiscard! if support_user.discarded?
      support_user.save!
    end
  end

  def validate_support_user
    if support_user.invalid?
      support_user.errors.each do |err|
        errors.add(err.attribute, err.message)
      end
    end
  end

  def user_klass
    { claims: Claims::SupportUser,
      placements: Placements::SupportUser }.fetch service
  end
end
