class Placements::Providers::Users::AddUserController < Placements::Organisations::Users::AddUserController
  private

  def set_organisation
    @organisation = set_provider
  end

  def step_path(step)
    add_user_placements_provider_users_path(step:)
  end

  def index_path
    placements_provider_users_path(@organisation)
  end
end
