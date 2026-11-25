module DfESignIn
  # Merges a never-used record into the user, only when the user matched by uid.
  class MergeUnusedUser < ApplicationService
    class Referenced < StandardError; end

    def initialize(current_user:, sign_in_user:)
      @current_user = current_user
      @sign_in_user = sign_in_user
    end

    def call
      return if current_user.support_user?
      return unless uid_match?

      ApplicationRecord.transaction do
        @unused_user = unused_users.lock.first

        if unused_user
          raise Referenced if referenced?

          move_memberships
          unused_user.reload.destroy!
        end
      end
    rescue Referenced, ActiveRecord::InvalidForeignKey
      Sentry.capture_message(
        "Could not merge unused user into signed in user",
        extra: { user_id: current_user.id, unused_user_id: unused_user.id },
      )
    end

    private

    attr_reader :current_user, :sign_in_user, :unused_user

    def uid_match?
      sign_in_user.dfe_sign_in_uid.present? &&
        current_user.dfe_sign_in_uid == sign_in_user.dfe_sign_in_uid.to_s
    end

    def unused_users
      current_user.class
        .where(email: sign_in_user.email, dfe_sign_in_uid: nil, last_signed_in_at: nil)
        .where.not(id: current_user.id)
    end

    def referenced?
      id = unused_user.id

      Claims::Claim.unscoped.where(created_by_id: id).or(Claims::Claim.unscoped.where(submitted_by_id: id)).exists? ||
        Placement.unscoped.where(creator_id: id).exists? ||
        School.unscoped.where(manually_onboarded_by_id: id).exists? ||
        Audited::Audit.where(user_id: id).exists?
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
