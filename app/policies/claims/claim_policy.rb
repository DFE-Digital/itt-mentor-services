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

  def confirm?
    !user.support_user? && record.submitted?
  end

  def draft?
    user.support_user? && record.internal?
  end

  def check?
    record.draft? || record.internal?
  end

  def download_csv?
    user.support_user?
  end
end
