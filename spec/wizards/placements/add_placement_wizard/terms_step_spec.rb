require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::TermsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:summer_term) { create(:placements_term, :summer) }
  let(:spring_term) { create(:placements_term, :spring) }
  let(:autumn_term) { create(:placements_term, :autumn) }
  let(:terms) { [summer_term, spring_term, autumn_term] }

  let(:school) { create(:placements_school) }

  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(term_ids: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:term_ids) }
  end

  describe "#terms_for_selection" do
    before do
      summer_term
      spring_term
      autumn_term
    end

    it "returns mentors for the school, ordered by name" do
      expect(step.terms_for_selection).to eq([
        summer_term, spring_term, autumn_term
      ])
    end
  end

  describe "#term_names" do
    context "when term_ids contains term ids" do
      let(:attributes) { { term_ids: [terms.pluck(:id)] } }

      it "returns the names of the terms as a string" do
        expect(step.term_names).to eq(
          "#{summer_term.name}, #{spring_term.name}, and #{autumn_term.name}",
        )
      end
    end

    context "when term_ids is 'any_term'" do
      let(:attributes) { { term_ids: %w[any_term] } }

      it "returns nil" do
        expect(step.term_names).to be_nil
      end
    end
  end

  describe "#term_ids=" do
    context "when the value is blank" do
      it "remains blank" do
        step.term_ids = []

        expect(step.term_ids).to eq([])
      end
    end

    context "when the value includes 'any_term'" do
      it "removes all values except any_term" do
        step.term_ids = ["any_term", summer_term.id]

        expect(step.term_ids).to eq(%w[any_term])
      end
    end

    context "when the value includes all 3 terms (summer, spring, autumn)" do
      it "return any_term" do
        step.term_ids = terms.pluck(:id).sort

        expect(step.term_ids).to eq(%w[any_term])
      end
    end

    context "when the value includes term ids (but not all term ids)" do
      before do
        summer_term
        spring_term
        autumn_term
      end

      it "retains the term ids" do
        step.term_ids = [summer_term.id]

        expect(step.term_ids).to match_array(summer_term.id)
      end
    end
  end
end
