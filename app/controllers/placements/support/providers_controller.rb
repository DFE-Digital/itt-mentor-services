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
    if @provider.valid? && @provider_details.present?
      provider_address(@provider_details)
    else
      render :new
    end
  end

  private

  def provider_params
    params.require(:provider).permit(:provider_code)
  end

  # TODO: Temporary until Provider imports have been implemented
  def provider_address(provider_details)
    @provider_address ||= begin
      address_parts = [
        provider_details.dig("attributes", "street_address_1"),
        provider_details.dig("attributes", "street_address_2"),
        provider_details.dig("attributes", "street_address_3"),
        provider_details.dig("attributes", "city"),
        provider_details.dig("attributes", "county"),
        provider_details.dig("attributes", "postcode"),
      ]
      address_parts.reject!(&:blank?)
      address_parts.join("<br/>").html_safe
    end
  end
end
