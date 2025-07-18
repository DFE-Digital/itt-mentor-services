class Claims::Support::ClaimsRemindersController < Claims::Support::ApplicationController
  before_action :skip_authorization
  before_action :set_claim_window
  before_action :set_schools, only: %i[schools_not_submitted_claims send_schools_not_submitted_claims]
  before_action :set_providers, only: %i[providers_not_submitted_claims send_providers_not_submitted_claims]

  def schools_not_submitted_claims; end

  def send_schools_not_submitted_claims
    users_to_notify = Claims::User.joins(:schools).where(schools: { id: @schools.ids })

    NotifyRateLimiter.call(collection: users_to_notify, mailer: "Claims::UserMailer", mailer_method: :claims_have_not_been_submitted)

    redirect_to schools_not_submitted_claims_claims_support_claims_reminders_path, flash: {
      heading: t(".success"),
      body: t(".success_body"),
    }
  end

  def providers_not_submitted_claims; end

  def send_providers_not_submitted_claims
    time_to_wait = 0.minutes
    email_addresses_to_notify = ProviderEmailAddress.includes(:provider).where(provider: @providers)

    email_addresses_to_notify.find_in_batches(batch_size: 100) do |email_batch|
      email_batch.each do |email|
        Claims::ProviderMailer.claims_have_not_been_submitted(provider_name: email.provider_name, email_address: email.email_address).deliver_later(wait: time_to_wait)
      end

      time_to_wait += 1.minute
    end

    redirect_to providers_not_submitted_claims_claims_support_claims_reminders_path, flash: {
      heading: t(".success"),
      body: t(".success_body"),
    }
  end

  private

  def set_claim_window
    @claim_window = Claims::ClaimWindow.current.decorate
  end

  def set_schools
    @schools = Claims::School.includes(:eligible_claim_windows)
                             .where(eligible_claim_windows: { id: @claim_window.id })
                             .where.missing(:claims)
  end

  def set_providers
    @providers = Claims::Provider.accredited.left_outer_joins(:claims)
                                 .where(claims: { id: nil })
                                 .or(
                                   Claims::Provider.left_outer_joins(:claims)
                                                   .where.not(claims: { claim_window_id: Claims::ClaimWindow.current.id }),
                                 )
                                 .distinct
  end
end
