class Placements::Support::Providers::Users::AddUserController < Placements::Organisations::Users::AddUserController
  private

  def set_organisation
    provider_id = params.require(:provider_id)
    @organisation = Placements::Provider.find(provider_id)
  end

  def step_path(step)
    add_user_placements_support_provider_users_path(step:)
  end

  def index_path
    placements_support_provider_users_path(@organisation)
  end
end