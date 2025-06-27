class Claims::Support::ProviderPolicy < Claims::ApplicationPolicy
  def search?
    user.support_user?
  end
end
