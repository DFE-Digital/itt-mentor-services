# == Schema Information
#
# Table name: terms
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Placements::Term, type: :model do
  describe "validations" do
    let(:term_names) { ["Spring term", "Summer term", "Autumn term"] }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:name).in_array(term_names) }
  end

  describe "associations" do
    it { is_expected.to have_many(:placement_windows).class_name("Placements::PlacementWindow") }
    it { is_expected.to have_many(:placements).through(:placement_windows) }
  end

  describe "scopes" do
    describe "#order_by_term" do
      let!(:autumn_term) { create(:placements_term, :autumn) }
      let!(:spring_term) { create(:placements_term, :spring) }
      let!(:summer_term) { create(:placements_term, :summer) }

      it "returns a collection of terms, in the order of Summer, Spring, Autumn" do
        expect(described_class.order_by_term).to eq([autumn_term, spring_term, summer_term])
      end
    end
  end
end
