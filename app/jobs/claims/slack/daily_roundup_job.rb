class Claims::Slack::DailyRoundupJob < ApplicationJob
  queue_as :default
  include MoneyRails::ActionViewExtension

  def perform
    current_claim_window = Claims::ClaimWindow.current
    return unless current_claim_window

    claim_window_academic_year = current_claim_window.academic_year
    todays_claims = claims_since(Time.current.yesterday.change(hour: 16))
    new_schools = new_organisations(todays_claims, :school_id)
    new_providers = new_organisations(todays_claims, :provider_id)
    total_claims = Claims::Claim.joins(:claim_window).where(claim_window: { academic_year_id: claim_window_academic_year.id })
    total_amount = total_claims.map(&:amount).sum
    average_amount = total_amount / total_claims.count.to_f

    Claims::ClaimSlackNotifier.claim_submitted_notification(
      academic_year: claim_window_academic_year,
      claim_count: todays_claims.count,
      school_count: new_schools.count,
      provider_count: new_providers.count,
      claim_amount: humanized_money_with_symbol(todays_claims.map(&:amount).sum),
      total_claims_count: total_claims.count,
      total_claims_amount: humanized_money_with_symbol(total_amount),
      invalid_claim_count: total_claims.where(status: :invalid_provider).count,
      average_claim_amount: humanized_money_with_symbol(average_amount),
    ).deliver_now
  end

  private

  def claims_since(timestamp)
    Claims::Claim.where(created_at: timestamp..).includes(:school, :provider)
  end

  def new_organisations(claims, entity_column)
    entity_ids = claims.select(entity_column)
    Claims::School.where(id: entity_ids).where.not(
      id: Claims::Claim.where("created_at < ?", Time.current.yesterday.change(hour: 16)).select(entity_column),
    )
  end
end
