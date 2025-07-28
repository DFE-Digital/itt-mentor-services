class Claims::ExportUsers < ApplicationService
  attr_reader :claim_window_id, :activity_level

  def initialize(claim_window_id:, activity_level:)
    @claim_window_id = claim_window_id
    @activity_level  = activity_level
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << %w[school_urn school_name user_first_name user_last_name email_address]

      membership_rows.each do |row|
        csv << [
          row.school_urn,
          row.school_name,
          row.user_first_name,
          row.user_last_name,
          row.email_address,
        ]
      end
    end
  end

  private

  def membership_rows
    scope = base_membership_scope
    scope = scope_for_claim_window(scope)
    scope = scope_for_activity_level(scope)
    scope = project_membership_row(scope)
    scope = order_membership_rows(scope)

    scope.distinct
  end

  def base_membership_scope
    UserMembership
      .where(organisation_type: "School")
      .joins(:user)
      .joins("INNER JOIN schools ON schools.id = user_memberships.organisation_id")
      .joins("INNER JOIN claims  ON claims.school_id = schools.id")
      .unscope(:order) # drop any default orders from associations
      .reorder(nil)
  end

  def scope_for_claim_window(scope)
    return scope if claim_window_id == "all"

    scope.where(claims: { claim_window_id: claim_window_id })
  end

  def scope_for_activity_level(scope)
    return scope if activity_level == "all"

    scope.where.not(users: { last_signed_in_at: nil })
  end

  def project_membership_row(scope)
    scope.select(
      "users.first_name AS user_first_name",
      "users.last_name  AS user_last_name",
      "users.email      AS email_address",
      "schools.urn      AS school_urn",
      "schools.name     AS school_name",
      "user_memberships.user_id         AS _user_id",
      "user_memberships.organisation_id AS _school_id",
    )
  end

  def order_membership_rows(scope)
    scope.order("user_last_name ASC, user_first_name ASC, school_name ASC")
  end
end
