class Claims::Support::ClaimPolicy < Claims::ApplicationPolicy
  def create?
    current_claim_window?
  end

  def create_exceptional?
    return false unless user.support_user?
    return true if record.is_a?(Class)

    record.claim_window.present? && record.claim_window.past?
  end

  def edit?
    claim_claim_window_current? && record.in_draft?
  end

  def update?
    edit?
  end

  def create_revision?
    edit?
  end

  def submit?
    current_claim_window? && !user.support_user? && record.in_draft?
  end

  def rejected?
    submit? || draft?
  end

  def destroy?
    record.draft? || (record.submitted? && user.support_user?)
  end

  # TODO: Remove record.draft? and not create drafts for existing drafts
  def draft?
    current_claim_window? && user.support_user? && record.in_draft?
  end

  def check?
    record.in_draft?
  end

  def download_csv?
    user.support_user?
  end

  def approve_clawback?
    record.clawback_requires_approval? && user.support_user?
  end

  def move_to_clawback?
    user.support_user? && record.sampling_provider_not_approved? && record.amendment_deadline_passed?
  end

  private

  def current_claim_window?
    Claims::ClaimWindow.current.present?
  end

  def claim_claim_window_current?
    record.claim_window.current?
  end
end
