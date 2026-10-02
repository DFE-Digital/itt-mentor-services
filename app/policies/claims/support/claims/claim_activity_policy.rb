class Claims::Support::Claims::ClaimActivityPolicy < Claims::ApplicationPolicy
  def resend_payer_email?
    true
  end
end
