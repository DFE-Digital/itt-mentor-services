# == Schema Information
#
# Table name: key_stages
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

RSpec.describe Placements::KeyStage, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:name).in_array(described_class::VALID_NAMES) }
  end

  describe ".order_by_name" do
    it "orders key stages alphabetically by name" do
      key_stage_2 = create(:key_stage, name: described_class::KEY_STAGE_2)
      early_years = create(:key_stage, name: described_class::EARLY_YEARS)

      expect(described_class.order_by_name).to eq([early_years, key_stage_2])
    end
  end

  describe "#name_as_attribute" do
    it "returns the name as a snake case symbol" do
      key_stage = build(:key_stage, name: described_class::KEY_STAGE_1)

      expect(key_stage.name_as_attribute).to eq(:key_stage_1)
    end
  end
end
