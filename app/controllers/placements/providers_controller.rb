class Placements::ProvidersController < Placements::ApplicationController
  def show
    @provider = current_user.providers.find(params.require(:id)).decorate
  end
end
