class Claims::Support::Claims::Payments::ClaimPolicy < Claims::ApplicationPolicy
  def update?
    false
  end

  def confirm_information_sent?
    information_sent?
  end

  def information_sent?
    record.payment_information_requested?
  end

  def confirm_paid?
    paid?
  end

  def paid?
    record.payment_information_sent?
  end

  def confirm_reject?
    reject?
  end

  def reject?
    record.payment_information_requested? || record.payment_information_sent?
  end
end
