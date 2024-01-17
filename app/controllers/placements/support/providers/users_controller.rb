class Placements::Support::Providers::UsersController < Placements::Support::Organisations::UsersController
  private

  def set_organisation
    @organisation = @provider = Placements::Provider.find(params[:provider_id])
  end

  def redirect_to_index
    redirect_to placements_support_provider_users_path(@provider)
  end
end
