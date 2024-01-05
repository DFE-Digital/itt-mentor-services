class Placements::Support::ProvidersController < Placements::Support::ApplicationController
  def new
    @provider = Provider.new
  end

  def create
    if provider.update(placements: true)
      redirect_to placements_support_organisations_path
    else
      render :new
    end
  end

  def check
    @provider = provider.decorate
    return if @provider.valid?

    render :new
  end

  private

  def provider
    @provider ||= Provider.find_by(code: provider_code, placements: false) || unknown_provider
  end

  def unknown_provider
    Provider.new(name: "Unknown Provider", provider_type: "university", code: provider_code)
  end

  def provider_code
    params.dig(:provider, :search_code)
  end
end
