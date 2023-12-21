class Placements::OrganisationsController < ApplicationController
  def index
    @schools = current_user.schools
    @providers = current_user.providers
  end
end
