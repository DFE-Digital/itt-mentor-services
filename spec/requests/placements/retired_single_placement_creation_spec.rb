require "rails_helper"

RSpec.describe "Retired individual placement creation", service: :placements, type: :request do
  let(:school) { create(:placements_school) }
  let(:current_user) { create(:placements_user, schools: [school]) }
  let(:placements_path) { "/schools/#{school.id}/placements" }
  let(:wizard_path) { "#{placements_path}/new/state/check_your_answers" }

  before { sign_in_as current_user }

  it "does not expose the retired entry point" do
    expect { get "#{placements_path}/new" }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "does not route to the retired wizard steps" do
    expect { get wizard_path }.to raise_error(ActionController::RoutingError)
  end

  it "does not route to the retired pre-publication preview" do
    expect { get "#{placements_path}/new/state/preview_placement" }.to raise_error(ActionController::RoutingError)
  end

  it "does not accept retired wizard submissions" do
    expect { put wizard_path }.to raise_error(ActionController::RoutingError)
  end

  it "does not accept implicit resource creation" do
    expect { post placements_path }.to raise_error(ActionController::RoutingError)
  end
end
