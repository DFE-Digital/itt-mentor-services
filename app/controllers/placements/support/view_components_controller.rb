class Placements::Support::ViewComponentsController < Placements::ApplicationController
  skip_after_action :verify_policy_scoped

  def index
    @previews = ViewComponent::Preview.all.filter { |preview| !preview.preview_name.start_with?("claims/") }.sort_by(&:preview_name)
  end
end
