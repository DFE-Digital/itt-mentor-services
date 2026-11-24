module DfESignIn
  # A person re-added under a new email gets a second user record that is never
  # signed into: their existing DfE Sign In account resolves to the original
  # record by uid. Hand the unused record's memberships to the record they sign
  # in as, and delete it so its email is free.
  class MergeUnusedUser < ApplicationService
    def initialize(current_user:, sign_in_user:)
      @current_user = current_user
      @sign_in_user = sign_in_user
    end

    def call
      return if current_user.support_user?
      return if unused_user.nil?

      ApplicationRecord.transaction do
        move_memberships
        unused_user.reload.destroy!
      end
    rescue ActiveRecord::InvalidForeignKey
      Sentry.capture_message(
        "Could not merge unused user into signed in user",
        extra: { user_id: current_user.id, unused_user_id: unused_user.id },
      )
    end

    private

    attr_reader :current_user, :sign_in_user

    def unused_user
      @unused_user ||= current_user.class
        .where(email: sign_in_user.email, dfe_sign_in_uid: nil, last_signed_in_at: nil)
        .where.not(id: current_user.id)
        .first
    end

    def move_memberships
      existing_organisation_ids = current_user.user_memberships.pluck(:organisation_id)

      unused_user.user_memberships.each do |membership|
        if existing_organisation_ids.include?(membership.organisation_id)
          membership.destroy!
        else
          membership.update!(user: current_user)
        end
      end
    end
  end
end
