module DfESignIn
  class UserUpdate < ApplicationService
    attr_reader :current_user, :successful
    alias_method :successful?, :successful

    def initialize(current_user:, sign_in_user:)
      @current_user = current_user
      @sign_in_user = sign_in_user
    end

    def call
      current_user.assign_attributes(attributes)
      @successful = current_user.valid? && current_user.save!

      self
    end

    private

    attr_reader :sign_in_user

    def attributes
      attributes = {
        last_signed_in_at: Time.current,
        dfe_sign_in_uid: sign_in_user.dfe_sign_in_uid,
      }

      attributes[:email] = sign_in_user.email unless email_clash?
      attributes[:first_name] = sign_in_user.first_name if sign_in_user.first_name.present?
      attributes[:last_name] = sign_in_user.last_name if sign_in_user.last_name.present?
      attributes
    end

    # Another record of the same type already has the DfE Sign In email, so the
    # email can't be updated without breaking uniqueness. Keep the existing email
    # and record the sign in, and flag it so support can look at the duplicate.
    def email_clash?
      other_user = current_user.class.unscoped
        .where(email: sign_in_user.email)
        .where.not(id: current_user.id)
        .first
      return false if other_user.nil?

      Sentry.capture_message(
        "DfE Sign In email already belongs to another user",
        extra: { user_id: current_user.id, other_user_id: other_user.id },
      )
      true
    end
  end
end
