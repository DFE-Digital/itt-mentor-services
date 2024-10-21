class Placement::StatusTagComponentPreview < ApplicationComponentPreview
  def default
    placement = FactoryBot.build(:placement)

    render(Placement::StatusTagComponent.new(placement:))
  end
end
