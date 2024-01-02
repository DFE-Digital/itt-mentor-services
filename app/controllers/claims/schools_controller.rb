class Claims::SchoolsController < ApplicationController
  def index
    @schools = current_user.schools
  end
end
