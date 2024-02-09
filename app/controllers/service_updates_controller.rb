class ServiceUpdatesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]

  def index
    @service_name ||= current_service
    @service_updates = ServiceUpdate.where(service: @service_name)
  end
end
