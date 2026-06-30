class Claims::UserResearch::ProviderSessionsController < Claims::ApplicationController
  skip_before_action :authenticate_user!
  before_action :skip_authorization
  def new; end

  def create
    provider = prototype.provider_for(
      code: params[:provider_code],
      email: params[:email],
    )
    if provider
      session[:provider_research_code] = provider.code
      redirect_to claims_user_research_provider_claims_path
    else
      flash.now[:heading] = "There is a problem"
      flash.now[:message] = "Enter the provider code and email from your research invite."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    session.delete(:provider_research_code)
    redirect_to claims_root_path
  end

  private

  def prototype
    @prototype ||= Claims::UserResearch::ProviderClaimsPrototype.new
  end
end
