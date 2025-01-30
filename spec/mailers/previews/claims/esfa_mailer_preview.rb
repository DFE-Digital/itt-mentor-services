class Claims::ESFAMailerPreview < ActionMailer::Preview
  def claims_require_clawback
    Claims::ESFAMailer.claims_require_clawback("https://example.com")
  end

  def resend_claims_require_clawback
    Claims::ESFAMailer.resend_claims_require_clawback("https://example.com")
  end
end
