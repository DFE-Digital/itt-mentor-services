class Placement::SummaryComponentPreview < ApplicationComponentPreview
  def default
    placement = create(:placement)

    render(Placement::StatusTagComponent.new(placement:))
  end
end
