class Claims::ClaimPolicy < Claims::ApplicationPolicy
  def edit?
    !record.submitted?
  end

  def update?
    edit?
  end

  def submit?
    !user.support_user? && !record.submitted?
  end

  def destroy?
    user.support_user? && record.draft?
  end

  def confirmation?
    !user.support_user? && record.submitted?
  end

  # TODO: Remove record.draft? and not create drafts for existing drafts
  def draft?
    user.support_user? && (record.internal_draft? || record.draft?)
  end

  def check?
    record.draft? || record.internal_draft?
  end

  def download_csv?
    user.support_user?
  end
end
