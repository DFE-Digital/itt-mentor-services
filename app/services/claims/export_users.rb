class Claims::ExportUsers < ApplicationService
  attr_reader :claim_window_id, :activity_level

  def initialize(claim_window_id:, activity_level:)
    @claim_window_id = claim_window_id
    @activity_level = activity_level
  end

  def call
    scope = users_with_claims_for_claim_window
    users = filter_by_activity_level(scope)

    CSV.generate(headers: true) do |csv|
      csv << %w[ID Name Email]

      users.find_each do |user|
        csv << [
          user.id,
          user.first_name,
          user.email,
        ]
      end
    end
  end

  def users_with_claims_for_claim_window
    memberships = UserMembership
      .where(organisation_type: "School")
      .joins("INNER JOIN claims ON claims.school_id = user_memberships.organisation_id")

    memberships = memberships.where(claims: { claim_window_id: }) unless claim_window_id == "all"

    user_ids = memberships.distinct.pluck(:user_id)

    User.where(id: user_ids)
  end

  def filter_by_activity_level(scope)
    return scope if activity_level == "all"

    scope.where.not(last_signed_in_at: nil)
  end
end
