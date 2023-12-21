class Claims::OrganisationsController < ApplicationController
  def index
    @schools = current_user.schools
  end
end
