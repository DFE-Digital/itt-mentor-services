require "rails_helper"

RSpec.describe Placements::SchoolPolicy do
  subject(:school_policy) { described_class }

  describe "scope" do
    let(:scope) { Placements::School.all }

    before do
      create_list(:placements_school, 3)
    end

    context "when the user is a support user" do
      let(:user) { create(:placements_support_user) }

      it "returns all schools" do
        expect(school_policy::Scope.new(user, scope).resolve).to eq(scope)
      end
    end

    context "when the user is assigned with a provider" do
      let(:school) { build(:placements_school) }
      let(:user) { create(:placements_user, schools: [school]) }

      it "returns the school's placements" do
        expect(school_policy::Scope.new(user, scope).resolve).to contain_exactly(school)
      end
    end
  end

  permissions :edit_potential_placements? do
    let(:selected_academic_year) { Placements::AcademicYear.current.next }
    let(:current_user) { create(:placements_user, schools: [school], selected_academic_year:) }
    let(:school) do
      build(:placements_school, potential_placement_details:)
    end
    let(:potential_placement_details) { nil }
    let(:hosting_interest) do
      create(:hosting_interest, school:, academic_year: selected_academic_year, appetite:)
    end

    before { hosting_interest }

    context "when the hosting interest is not 'interested'" do
      let(:appetite) { "actively_looking" }

      it "denies access" do
        expect(school_policy).not_to permit(current_user, school)
      end
    end

    context "when the hosting interest is not 'actively_looking'" do
      let(:appetite) { "interested" }

      context "when the school does not have potential placement details" do
        it "denies access" do
          expect(school_policy).not_to permit(current_user, school)
        end
      end

      context "when the school does have potential placement details" do
        let(:potential_placement_details) do
          { "appetite" => { "appetite" => "interested" } }
        end

        it "grantes access" do
          expect(school_policy).to permit(current_user, school)
        end
      end
    end
  end
end
