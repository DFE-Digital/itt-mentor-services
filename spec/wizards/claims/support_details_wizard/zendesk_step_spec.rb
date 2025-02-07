require "rails_helper"

RSpec.describe Claims::SupportDetailsWizard::ZendeskStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::SupportDetailsWizard)
  end
  let(:claim) { create(:claim) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(zendesk_url: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:zendesk_url) }
  end
end
