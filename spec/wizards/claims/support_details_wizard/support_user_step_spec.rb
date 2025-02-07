require "rails_helper"

RSpec.describe Claims::SupportDetailsWizard::SupportUserStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::SupportDetailsWizard)
  end
  let(:support_user) { create(:claims_support_user) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(support_user_id: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:support_user_id) }
    it { is_expected.to validate_inclusion_of(:support_user_id).in_array(Claims::SupportUser.ids) }
  end
end
