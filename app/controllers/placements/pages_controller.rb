class Placements::PagesController < ApplicationController
  skip_before_action :authenticate_user!
end
