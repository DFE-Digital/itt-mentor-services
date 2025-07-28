# app/services/claims/export_users.rb
class Claims::ExportUsers < ApplicationService
  attr_reader :claim_window_id, :activity_level

  def initialize(claim_window_id:, activity_level:)
    @claim_window_id = claim_window_id
    @activity_level  = activity_level
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << %w[school_urn school_name user_first_name user_last_name email_address]

      membership_rows.each do |school_urn, school_name, user_first_name, user_last_name, email_address|
        csv << [school_urn, school_name, user_first_name, user_last_name, email_address]
      end
    end
  end

  private

  def membership_rows
    scope = base_scope
    scope = scope_for_claim_window(scope)
    scope = scope_for_activity_level(scope)
    scope = order_membership_rows(scope)

    scope
      .distinct
      .pluck(
        :urn,
        :name,
        "users.first_name",
        "users.last_name",
        "users.email",
      )
  end

  def base_scope
    Claims::Claim.joins(school: { user_memberships: :user })
  end

  def scope_for_claim_window(scope)
    return scope if claim_window_id == "all"

    scope.where(claim_window_id: claim_window_id)
  end

  def scope_for_activity_level(scope)
    return scope if activity_level == "all"

    scope.where.not(users: { last_signed_in_at: nil })
  end

  def order_membership_rows(scope)
    scope
      .merge(School.order_by_name)
      .order(users: { last_name: :asc, first_name: :asc })
  end
end
