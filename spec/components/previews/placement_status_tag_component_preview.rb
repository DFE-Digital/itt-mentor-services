class PlacementStatusTagComponentPreview < ApplicationComponentPreview
  def draft_status
    render Placement::StatusTagComponent.new("draft")
  end

  def published_status
    render Placement::StatusTagComponent.new("published")
  end
end
