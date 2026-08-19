require "rails_helper"

RSpec.describe Claims::Providers::Claims::StatusesQuery do
  describe ".values" do
    it "returns the provider-card statuses in display order" do
      expect(described_class.values).to eq(
        %w[
          sampling_in_progress
          sampling_provider_not_approved
          paid
        ],
      )
    end
  end
end
