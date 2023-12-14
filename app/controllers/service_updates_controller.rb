# frozen_string_literal: true

class ServiceUpdatesController < ApplicationController
  include ApplicationHelper

  def index
    @service_name ||= current_service
    @service_updates = ServiceUpdate.where(service: @service_name)
  end
end
