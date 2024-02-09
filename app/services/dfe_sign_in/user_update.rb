module DfESignIn
  class UserUpdate
    include ServicePattern

    attr_reader :current_user, :successful
    alias_method :successful?, :successful

    def initialize(current_user:, sign_in_user:)
      @current_user = current_user

      attributes = {
        last_signed_in_at: Time.current,
        email: sign_in_user.email,
        dfe_sign_in_uid: sign_in_user.dfe_sign_in_uid,
      }

      attributes[:first_name] = sign_in_user.first_name if sign_in_user.first_name.present?
      attributes[:last_name] = sign_in_user.last_name if sign_in_user.last_name.present?

      current_user.assign_attributes(attributes)
    end

    def call
      @successful = current_user.valid? && current_user.save!

      self
    end
  end
end
