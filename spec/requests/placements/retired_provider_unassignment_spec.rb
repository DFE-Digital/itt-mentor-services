require "rails_helper"

RSpec.describe "Retired provider unassignment", service: :placements, type: :request do
  let(:placement_path) { "/schools/school/placements/placement" }

  it "does not route to the retired confirmation" do
    expect { get "#{placement_path}/confirm_unassign_provider" }.to raise_error(ActionController::RoutingError)
  end

  it "does not accept retired unassignment submissions" do
    expect { put "#{placement_path}/unassign_provider" }.to raise_error(ActionController::RoutingError)
  end
end
