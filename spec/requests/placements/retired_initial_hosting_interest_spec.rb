require "rails_helper"

RSpec.describe "Retired initial hosting-interest submission", service: :placements, type: :request do
  let(:new_path) { "/schools/school/hosting_interests/new" }
  let(:wizard_path) { "#{new_path}/state/appetite" }

  it "does not route to the retired entry point" do
    expect { get new_path }.to raise_error(ActionController::RoutingError)
  end

  it "does not route to the retired wizard steps" do
    expect { get wizard_path }.to raise_error(ActionController::RoutingError)
  end

  it "does not accept retired wizard submissions" do
    expect { put wizard_path }.to raise_error(ActionController::RoutingError)
  end

  it "does not accept implicit resource creation" do
    expect { post "/schools/school/hosting_interests" }.to raise_error(ActionController::RoutingError)
  end
end
