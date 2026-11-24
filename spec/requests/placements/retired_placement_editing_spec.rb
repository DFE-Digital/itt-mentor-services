require "rails_helper"

RSpec.describe "Retired placement editing", service: :placements, type: :request do
  let(:edit_path) { "/schools/school/placements/placement/edit" }

  it "does not route to the retired edit wizard" do
    expect { get edit_path }.to raise_error(ActionController::RoutingError)
  end

  it "does not route to retired edit wizard steps" do
    expect { get "#{edit_path}/state/provider" }.to raise_error(ActionController::RoutingError)
  end

  it "does not accept retired edit wizard submissions" do
    expect { put "#{edit_path}/state/provider" }.to raise_error(ActionController::RoutingError)
  end
end
