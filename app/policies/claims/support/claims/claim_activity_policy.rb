class Claims::Support::Claims::ClaimActivityPolicy < Claims::ApplicationPolicy
  def resend_payer_email?
    true
  end

  def resend_provider_email?
    true
  end
end
