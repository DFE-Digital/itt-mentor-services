class Claims::Support::ClaimsRemindersController < Claims::Support::ApplicationController
  before_action :skip_authorization
  before_action :set_claim_window
  before_action :set_schools, only: %i[schools_not_submitted_claims send_schools_not_submitted_claims]
  before_action :set_providers, only: %i[providers_not_submitted_claims send_providers_not_submitted_claims]
  before_action :schools_without_sign_in, only: %i[schools_not_signed_in send_schools_not_signed_in]
  before_action :schools_with_sign_ins_without_claims, only: %i[school_has_signed_in_but_not_claimed send_your_school_has_signed_in_but_not_claimed]

  def schools_not_submitted_claims; end

  def send_schools_not_submitted_claims
    users_to_notify = Claims::User.joins(:schools).where(schools: { id: @schools.ids })

    NotifyRateLimiter.call(
      collection: users_to_notify,
      mailer: "Claims::UserMailer",
      mailer_method: :claims_have_not_been_submitted,
    )

    redirect_to schools_not_submitted_claims_claims_support_claims_reminders_path, flash: {
      heading: t(".success"),
      body: t(".success_body"),
    }
  end

  def providers_not_submitted_claims; end

  def send_providers_not_submitted_claims
    email_addresses_to_notify = ProviderEmailAddress.includes(:provider).where(provider: @providers)

    NotifyRateLimiter.call(
      collection: email_addresses_to_notify,
      mailer: "Claims::ProviderMailer",
      mailer_method: :claims_have_not_been_submitted,
    )

    redirect_to providers_not_submitted_claims_claims_support_claims_reminders_path, flash: {
      heading: t(".success"),
      body: t(".success_body"),
    }
  end

  def schools_not_signed_in; end

  def send_schools_not_signed_in
    email_addresses_to_notify = Claims::User.joins(:schools).where(schools: { id: @schools_without_sign_in.ids }).distinct

    return unless email_addresses_to_notify.exists?

    NotifyRateLimiter.call(
      collection: email_addresses_to_notify,
      mailer: "Claims::UserMailer",
      mailer_method: :your_school_has_not_signed_in,
    )

    redirect_to schools_not_signed_in_claims_support_claims_reminders_path, flash: {
      heading: t(".success"),
      body: t(".success_body"),
    }
  end

  def school_has_signed_in_but_not_claimed; end

  def send_your_school_has_signed_in_but_not_claimed
    email_addresses_to_notify = Claims::User.joins(:schools).where(schools: { id: @schools_with_sign_ins_without_claims.ids }).distinct

    return unless email_addresses_to_notify.exists?

    NotifyRateLimiter.call(
      collection: email_addresses_to_notify,
      mailer: "Claims::UserMailer",
      mailer_method: :your_school_has_signed_in_but_not_claimed,
    )

    redirect_to schools_not_signed_in_claims_support_claims_reminders_path, flash: {
      heading: t(".success"),
      body: t(".success_body"),
    }
  end

  private

  def set_claim_window
    @claim_window = Claims::ClaimWindow.current&.decorate
  end

  def eligible_claim_windows
    @eligible_claim_windows ||= Claims::ClaimWindow.where(academic_year_id: @claim_window.academic_year_id)
  end

  def set_schools
    @schools = Claims::School.includes(:eligible_claim_windows)
                             .where(eligible_claim_windows: { id: eligible_claim_windows.ids })
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

  def schools_without_sign_in
    @schools_without_sign_in ||= Claims::School
                                .includes(:users)
                                .where(users: { last_signed_in_at: nil })
                                .where.not(id: Claims::School.joins(:users).where.not(users: { last_signed_in_at: nil }))
  end

  def schools_with_sign_ins_without_claims
    @schools_with_sign_ins_without_claims ||= Claims::School
                                            .joins(:users)
                                            .where.not(users: { last_signed_in_at: nil })
                                            .includes(:eligible_claim_windows)
                                            .where(eligible_claim_windows: { id: eligible_claim_windows.ids })
                                            .where.missing(:claims)
  end
end
