require "rails_helper"

RSpec.describe "Retired standalone bulk placement creation", service: :placements, type: :request do
  let(:school) { create(:placements_school) }
  let(:current_user) { create(:placements_user, schools: [school]) }
  let(:placements_path) { "/schools/#{school.id}/placements" }
  let(:wizard_path) { "#{placements_path}/multiple/state/phase" }

  before { sign_in_as current_user }

  it "does not accept bulk wizard steps" do
    expect { get wizard_path }.to raise_error(ActionController::RoutingError)
  end

  it "does not accept bulk wizard submissions" do
    expect { put wizard_path }.to raise_error(ActionController::RoutingError)
  end

  %w[multiple whats_next concept_index].each do |retired_path|
    it "does not expose the retired #{retired_path} page" do
      expect { get "#{placements_path}/#{retired_path}" }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
