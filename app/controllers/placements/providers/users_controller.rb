class Placements::Providers::UsersController < Placements::Organisations::UsersController
  before_action :set_provider

  private

  def set_organisation
    @organisation = current_user.providers.find(params.fetch(:provider_id))
  end

  def redirect_to_index
    redirect_to placements_provider_users_path(@organisation)
  end

  def set_provider
    session[:placements_provider_id] = @organisation.id
  end
end
