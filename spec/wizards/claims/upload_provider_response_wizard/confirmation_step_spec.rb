require "rails_helper"

RSpec.describe Claims::UploadProviderResponseWizard::ConfirmationStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadProviderResponseWizard)
  end
  let(:attributes) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:grouped_csv_rows).to(:wizard) }
  end
end
