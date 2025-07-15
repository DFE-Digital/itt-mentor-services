class Claims::ClaimPolicy < Claims::ApplicationPolicy
  def create?
    current_claim_window? && school_eligible_to_claim?
  end

  def edit?
    claim_claim_window_current? && record.in_draft? && school_eligible_to_claim?
  end

  def update?
    edit?
  end

  def create_revision?
    edit?
  end

  def invalid_provider?
    record.invalid_provider? && (record.created_by == user || user.support_user?)
  end

  def submit?
    current_claim_window? && record.in_draft? && school_eligible_to_claim?
  end

  def rejected?
    submit?
  end

  def destroy?
    record.draft?
  end

  def confirmation?
    !user.support_user? && record.submitted?
  end

  def check?
    record.in_draft?
  end

  private

  def current_claim_window?
    Claims::ClaimWindow.current.present?
  end

  def claim_claim_window_current?
    record.claim_window.current?
  end

  def school_eligible_to_claim?
    record.school.eligible_for_claim_window?(Claims::ClaimWindow.current)
  end
end
