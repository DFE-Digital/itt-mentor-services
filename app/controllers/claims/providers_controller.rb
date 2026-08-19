class Claims::ProvidersController < Claims::Providers::ApplicationController
  before_action :redirect_to_provider_claims_when_belongs_to_one_provider, only: :index
  before_action :authorize_provider

  def index
    @providers = policy_scope(Claims::Provider.order_by_name)
  end

  private

  def redirect_to_provider_claims_when_belongs_to_one_provider
    if policy_scope(Claims::Provider).one?
      redirect_to claims_provider_claims_path(policy_scope(Claims::Provider).first)
    end
  end

  def authorize_provider
    authorize Claims::Provider
  end
end
