require "rails_helper"

describe Placements::PlacementsQuery do
  subject(:placements_query) { described_class.call(params:) }

  let!(:school_1) do
    create(
      :placements_school,
      phase: "Primary",
      name: "School 1A",
      type_of_establishment: "Free school",
      gender: "Mixed",
      religious_character: "Jewish",
      rating: "Good",
    )
  end
  let!(:school_2) do
    create(
      :placements_school,
      phase: "Secondary",
      name: "School 2B",
      type_of_establishment: "Community school",
      gender: "Boys",
      religious_character: "Christian",
      rating: "Outstanding",
    )
  end
  let!(:subject_1) { create(:subject, name: "Subject 1A") }
  let!(:subject_2) { create(:subject, name: "Subject 2B") }
  let!(:placement_1) { create(:placement, subjects: [subject_1], school: school_1) }
  let!(:placement_2) { create(:placement, subjects: [subject_2], school: school_2) }

  context "when given no params" do
    let(:params) { {} }

    it "returns all placements, ordered by school name" do
      expect(placements_query).to eq([placement_1, placement_2])
    end
  end

  context "when given school phase params" do
    let(:params) { { school_phases: %w[Primary] } }

    it "returns placements associated to schools with phase" do
      expect(placements_query).to contain_exactly(placement_1)
    end
  end

  context "when given school id params" do
    let(:params) { { school_ids: [school_1.id] } }

    it "returns all placements associated to schools with the given school ids" do
      expect(placements_query).to contain_exactly(placement_1)
    end
  end

  context "when given subject id params" do
    let(:params) { { subject_ids: [subject_1.id] } }

    it "returns all placements associated to subjects with the given subject ids" do
      expect(placements_query).to contain_exactly(placement_1)
    end
  end

  context "when given school type params" do
    let(:params) { { school_types: ["Free school"] } }

    it "returns all placements associated to schools with the given school type" do
      expect(placements_query).to contain_exactly(placement_1)
    end
  end

  context "when given gender params" do
    let(:params) { { genders: %w[Mixed] } }

    it "returns all placements associated to schools with given gender" do
      expect(placements_query).to contain_exactly(placement_1)
    end
  end

  context "when given religious character params" do
    let(:params) { { religious_characters: %w[Jewish] } }

    it "returns all placements associated to schools with given religious character" do
      expect(placements_query).to contain_exactly(placement_1)
    end
  end

  context "when given ofsted rating params" do
    let(:params) { { ofsted_ratings: %w[Good] } }

    it "returns all placements associated to schools with given ofsted rating" do
      expect(placements_query).to contain_exactly(placement_1)
    end
  end
end
