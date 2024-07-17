class Claims::ClaimPolicy < Claims::ApplicationPolicy
  def create?
    Claims::ClaimWindow.current.present?
  end

  def edit?
    create? && !record.submitted?
  end

  def update?
    edit?
  end

  def create_revision?
    edit?
  end

  def submit?
    create? && !user.support_user? && !record.submitted?
  end

  def rejected?
    submit? || draft?
  end

  def destroy?
    record.draft?
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
