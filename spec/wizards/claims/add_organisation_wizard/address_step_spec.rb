require "rails_helper"

RSpec.describe Claims::AddOrganisationWizard::AddressStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::AddOrganisationWizard)
  end
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(address1: nil, address2: nil, town: nil, postcode: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:address1) }
    it { is_expected.to validate_presence_of(:town) }
    it { is_expected.to validate_presence_of(:postcode) }
  end
end
