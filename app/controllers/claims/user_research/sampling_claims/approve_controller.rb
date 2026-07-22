class Claims::UserResearch::SamplingClaims::ApproveController < Claims::ApplicationController
  skip_before_action :authenticate_user!
  before_action :skip_authorization
  before_action :redirect_unless_logged_in
  before_action :set_claim

  def new; end

  def create
    Claims::Claim::Sampling::Paid.call(claim: @claim)
    redirect_to claims_user_research_provider_claims_path, flash: {
      heading: t(".success"),
    }
  end

  private

  def redirect_unless_logged_in
    return if current_provider.present?

    redirect_to claims_root_path
  end

  def set_claim
    @claim = claims_scope.find(params.require(:id))
  end

  def claims_scope
    Claims::Claim.not_draft_status.includes(
      :claim_window,
      :provider,
      :academic_year,
      :mentor_trainings,
      :support_user,
      school: :region,
    ).where(provider_id: prototype_provider_ids)
  end

  def prototype_provider_ids
    @prototype_provider_ids ||= Claims::Provider.where(name: current_provider.name).select(:id)
  end

  def current_provider
    @current_provider ||= prototype.provider_for(code: session[:provider_research_code])
  end

  def prototype
    @prototype ||= Claims::UserResearch::ProviderClaimsPrototype.new
  end
end
