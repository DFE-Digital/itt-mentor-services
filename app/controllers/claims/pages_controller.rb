class Claims::PagesController < Claims::ApplicationController
  skip_before_action :authenticate_user!

  before_action :skip_authorization
end
