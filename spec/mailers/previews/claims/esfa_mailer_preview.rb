class Claims::ESFAMailerPreview < ActionMailer::Preview
  def claims_require_clawback
    Claims::ESFAMailer.claims_require_clawback("https://example.com")
  end
end
