class UserMailer < ApplicationMailer
  def user_membership_created_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", service_name:),
                 body: t(".body", user_name: user.first_name, organisation_name: organisation.name, service_name:, sign_in_url:)
  end

  def user_membership_destroyed_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", service_name:),
                 body: t(".body", user_name: user.first_name, organisation_name: organisation.name, service_name:)
  end

  def claim_submitted_notification(user, claim)
    link_to_claim = claims_school_claim_url(id: claim.id, school_id: claim.school.id)

    notify_email to: user.email,
                 subject: t(".subject"),
                 body: t(".body",
                         user_name: user.first_name,
                         organisation_name: claim.school.name,
                         reference: claim.reference,
                         amount: claim.amount.format(symbol: true, decimal_mark: ".", no_cents: false),
                         link_to_claim:)
  end

  def claim_created_support_notification(claim, user)
    link_to_claim = claims_school_claim_url(id: claim.id, school_id: claim.school.id)

    notify_email(to: user.email,
                 subject: t(".subject"),
                 body: t(".body",
                         user_name: user.first_name,
                         organisation_name: claim.school.name,
                         reference: claim.reference,
                         amount: claim.amount.format(symbol: true, decimal_mark: ".", no_cents: false),
                         sign_in_url:,
                         link_to_claim:))
  end
end
