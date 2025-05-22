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
  describe "associations" do
    it { is_expected.to have_many(:placement_key_stages) }
    it { is_expected.to have_many(:placements).through(:placement_key_stages) }
  end

  describe "validations" do
    let(:key_stage_names) do
      ["Early years", "Key stage 1", "Key stage 2", "Key stage 3", "Key stage 4", "Key stage 5"]
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:name).in_array(key_stage_names) }
  end

  describe "scopes" do
    describe "#order_by_name" do
      it "returns the key stages ordered by name" do
        key_stage_3 = create(:key_stage, name: "Key stage 3")
        key_stage_5 = create(:key_stage, name: "Key stage 5")
        early_years = create(:key_stage, name: "Early years")

        expect(described_class.order_by_name).to eq(
          [early_years, key_stage_3, key_stage_5],
        )
      end
    end
  end
end
