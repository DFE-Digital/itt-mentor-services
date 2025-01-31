class Claims::ClaimActivityDecorator < Draper::Decorator
  delegate_all

  def title
    case action
    when "payment_request_delivered"
      I18n.t("#{translation_path}.payment_request_delivered", count: record.claims.count)
    when "payment_response_uploaded"
      I18n.t("#{translation_path}.payment_response_uploaded")
    when "sampling_uploaded"
      I18n.t("#{translation_path}.sampling_uploaded", count: record.claims.count)
    when "sampling_response_uploaded"
      I18n.t("#{translation_path}.sampling_response_uploaded", count: record.claims.count)
    when "clawback_request_delivered"
      I18n.t("#{translation_path}.clawback_request_delivered", count: record.claims.count)
    when "clawback_response_uploaded"
      I18n.t("#{translation_path}.clawback_response_uploaded", count: record.claims.count)
    when "provider_approved_audit"
      I18n.t("#{translation_path}.provider_approved_audit", provider_name: record.provider_name, claim_reference: record.reference)
    when "rejected_by_provider"
      I18n.t("#{translation_path}.rejected_by_provider", provider_name: record.provider_name, claim_reference: record.reference)
    when "rejected_by_school"
      I18n.t("#{translation_path}.rejected_by_school", school_name: record.school_name, claim_reference: record.reference)
    when "approved_by_school"
      I18n.t("#{translation_path}.approved_by_school", school_name: record.school_name, claim_reference: record.reference)
    when "clawback_requested"
      I18n.t("#{translation_path}.clawback_requested", claim_reference: record.reference)
    when "rejected_by_payer"
      I18n.t("#{translation_path}.rejected_by_payer", claim_reference: record.reference)
    when "paid_by_payer"
      I18n.t("#{translation_path}.paid_by_payer", claim_reference: record.reference)
    when "information_sent_to_payer"
      I18n.t("#{translation_path}.information_sent_to_payer", claim_reference: record.reference)
    else
      raise "Unknown action: #{action}"
    end
  end

  private

  def translation_path
    "activerecord.attributes.claims/claim_activity/action"
  end
end
