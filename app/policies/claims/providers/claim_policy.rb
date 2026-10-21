class Claims::Providers::ClaimPolicy < Claims::Providers::ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?
      return scope.none unless provider_user?

      scope.where(provider_id: user.providers.select(:id))
    end

    private

    def provider_user?
      user.is_a?(Claims::ProviderUser)
    end
  end

  def read?
    return true if user.support_user?
    return false unless provider_user?

    user.providers.exists?(id: record.provider_id)
  end

  # Someone cannot audit a claim they created themselves, so another provider
  # user has to do it.
  def approve?
    read? && record.sampling_in_progress? && !own_claim?
  end

  def own_claim?
    user.same_person_as?(record.created_by)
  end

  def reject?
    approve?
  end

  def download?
    provider_user?
  end

  def search?
    index?
  end
end
