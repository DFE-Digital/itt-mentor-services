class UserMailer < ApplicationMailer
  def user_membership_created_notification(user, organisation)
    user_membership_notification(user, organisation, t(".#{service}.heading"), sign_in_url)
  end

  def user_membership_destroyed_notification(user, organisation)
    user_membership_notification(user, organisation)
  end

  def claim_submitted_notification(user, claim)
    claim_notification(user, claim)
  end

  def claim_created_support_notification(claim, user)
    claim_notification(user, claim)
  end

  def partnership_created_notification(user, source_organisation, partner_organisation)
    partnership_notification(user, source_organisation, partner_organisation)
  end

  def partnership_destroyed_notification(user, source_organisation, partner_organisation)
    partnership_notification(user, source_organisation, partner_organisation)
  end

  private

  def user_membership_notification(user, organisation, heading = nil, sign_in_url = nil)
    notify_email to: user.email,
                 subject: t(".subject", service_name:),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: organisation.name,
                   service_name:,
                   heading:,
                   support_email:,
                   sign_in_url:,
                 )
  end

  def partnership_notification(user, source_organisation, partner_organisation)
    if partner_organisation.is_a?(Provider)
      partner_class = "provider"
      link = placements_provider_partner_schools_url(partner_organisation)
    elsif partner_organisation.is_a?(School)
      partner_class = "school"
      link = placements_school_partner_providers_url(partner_organisation)
    else
      raise InvalidOrganisationError, "#partner_organisation must be either a Provider or School"
    end

    notify_email(
      to: user.email,
      subject: t(".subject.#{partner_class}", organisation: partner_organisation.name),
      body: t(
        ".body.#{partner_class}",
        user_name: user.full_name,
        source_organisation: source_organisation.name,
        partner_organisation: partner_organisation.name,
        link:,
      ),
    )
  end

  def claim_notification(user, claim)
    link_to_claim = claims_school_claim_url(id: claim.id, school_id: claim.school.id)

    notify_email to: user.email,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: claim.school.name,
                   reference: claim.reference,
                   amount: claim.amount.format(symbol: true, decimal_mark: ".", no_cents: false),
                   support_email:,
                   link_to_claim:,
                 )
  end
end

class InvalidOrganisationError < StandardError; end
