class Placements::Support::ProvidersController < Placements::Support::ApplicationController
  def new
    @provider = Provider.new
  end

  def create
    @provider = Provider.new(provider_params)
    if @provider.save
      redirect_to placements_support_organisations_path
    else
      render :new
    end
  end

  def check
    @provider = Provider.new(provider_code: params[:accredited_provider_id])
    @provider_details = AccreditedProviderApi.call(@provider.provider_code)
    return if @provider.valid? && @provider_details.present?

    render :new
  end

  private

  def provider_params
    params.require(:provider).permit(:provider_code)
  end
end
