class Claims::ESFAMailerPreview < ActionMailer::Preview
  def claims_require_clawback
    Claims::ESFAMailer.claims_require_clawback(clawback)
  end

  def resend_claims_require_clawback
    Claims::ESFAMailer.resend_claims_require_clawback(clawback)
  end

  private

  def clawback
    FactoryBot.build_stubbed(:clawback, csv_file: nil)
  end
end
