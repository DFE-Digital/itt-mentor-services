class Placements::Support::ProvidersController < Placements::ApplicationController
  def show
    @provider = Placements::Provider.find(params.require(:id)).decorate
  end
end
