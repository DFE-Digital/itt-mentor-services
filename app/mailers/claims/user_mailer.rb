class Claims::UserMailer < Claims::ApplicationMailer
  def user_membership_created_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", service_name:),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: organisation.name,
                   academic_year_name: Claims::ClaimWindow.current.academic_year_name,
                   service_name:,
                   support_email:,
                   sign_in_url: sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school"),
                   sign_in_approver_url: "https://edd-help.signin.education.gov.uk/contact/create-account#:~:text=An%20approver%20is%20someone%20at%20your%20organisation%20responsible,person%2C%20such%20as%20an%20administrator%2C%20manager%2C%20or%20headteacher",
                 )
  end

  def user_membership_destroyed_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", service_name:),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: organisation.name,
                   service_name:,
                   support_email:,
                 )
  end

  def claim_submitted_notification(user, claim)
    link_to_claim = claims_school_claim_url(id: claim.id, school_id: claim.school.id, utm_source: "email", utm_medium: "notification", utm_campaign: "school")

    notify_email to: user.email,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: claim.school_name,
                   reference: claim.reference,
                   amount: claim.amount.format(symbol: true, decimal_mark: ".", no_cents: false),
                   mentor_count: claim.mentors.count,
                   provider_name: claim.provider_name,
                   support_email:,
                   link_to_claim:,
                 )
  end

  def claim_created_support_notification(claim, user)
    link_to_claim = claims_school_claim_url(id: claim.id, school_id: claim.school.id, utm_source: "email", utm_medium: "notification", utm_campaign: "school")

    notify_email to: user.email,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: claim.school_name,
                   reference: claim.reference,
                   amount: claim.amount.format(symbol: true, decimal_mark: ".", no_cents: false),
                   support_email:,
                   link_to_claim:,
                 )
  end

  def claim_requires_clawback(claim, user)
    link_to_claim = claims_school_claim_url(id: claim.id, school_id: claim.school.id, utm_source: "email", utm_medium: "notification", utm_campaign: "school")

    notify_email to: user.email,
                 subject: t(".subject"),
                 body: t(".body",
                         user_name: user.first_name,
                         claim_reference: claim.reference,
                         clawback_amount: claim.total_clawback_amount.format(symbol: true, decimal_mark: ".", no_cents: false),
                         link_to_claim:,
                         support_email:,
                         service_name:,
                         service_url: claims_root_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school"))
  end
end
