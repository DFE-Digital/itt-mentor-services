require "rails_helper"

RSpec.describe "Retired placements hosting-status editing", service: :placements, type: :request do
  let(:edit_path) { "/schools/school/hosting_interests/interest/edit" }
  let(:wizard_path) { "#{edit_path}/state/appetite" }

  it "does not route to the retired edit entry point" do
    expect { get edit_path }.to raise_error(ActionController::RoutingError)
  end

  it "does not route to the retired wizard steps" do
    expect { get wizard_path }.to raise_error(ActionController::RoutingError)
  end

  it "does not accept updates to the retired wizard" do
    expect { put wizard_path }.to raise_error(ActionController::RoutingError)
  end
end
