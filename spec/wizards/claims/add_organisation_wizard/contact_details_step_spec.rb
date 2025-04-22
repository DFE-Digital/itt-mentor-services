require "rails_helper"

RSpec.describe Claims::AddOrganisationWizard::ContactDetailsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::AddOrganisationWizard)
  end
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(telephone: nil, website: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:telephone) }
    it { is_expected.to validate_presence_of(:website) }
  end
end
