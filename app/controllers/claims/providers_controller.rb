class Claims::ProvidersController < Claims::Providers::ApplicationController
  before_action :redirect_to_provider_claims_when_belongs_to_one_provider, only: :index
  before_action :authorize_provider

  def index
    @providers = providers.order_by_name
  end

  private

  def providers
    @providers ||= policy_scope(Claims::Provider)
  end

  def redirect_to_provider_claims_when_belongs_to_one_provider
    return unless providers.one?

    redirect_to claims_provider_claims_path(providers.first)
  end

  def authorize_provider
    authorize Claims::Provider
  end
end
