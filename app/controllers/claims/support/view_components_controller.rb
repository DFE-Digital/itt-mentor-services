class Claims::Support::ViewComponentsController < Claims::Support::ApplicationController
  before_action :skip_authorization

  def index
    @previews = ViewComponent::Preview.all.filter { |preview| !preview.preview_name.start_with?("placements/") }.sort_by(&:preview_name)
  end
end
