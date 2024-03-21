class ClaimPolicy < Claims::ApplicationPolicy
  def update?
    true
  end

  def submit?
    true
  end

  def confirm?
    true
  end

  def destroy?
    true
  end

  def download_csv?
    true
  end
end
