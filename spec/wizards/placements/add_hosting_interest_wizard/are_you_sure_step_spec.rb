require "rails_helper"

RSpec.describe Placements::AddHostingInterestWizard::AreYouSureStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddHostingInterestWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }

  describe "delegations" do
    it { is_expected.to delegate_method(:reasons_not_hosting).to(:reason_not_hosting_step) }
    it { is_expected.to delegate_method(:other_reason_not_hosting).to(:reason_not_hosting_step) }
    it { is_expected.to delegate_method(:first_name).to(:school_contact_step).with_prefix(:school_contact) }
    it { is_expected.to delegate_method(:last_name).to(:school_contact_step).with_prefix(:school_contact) }
    it { is_expected.to delegate_method(:email_address).to(:school_contact_step).with_prefix(:school_contact) }
  end
end
