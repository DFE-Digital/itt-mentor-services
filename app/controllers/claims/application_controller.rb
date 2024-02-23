class Claims::ApplicationController < ApplicationController
  after_action :verify_authorized
end
