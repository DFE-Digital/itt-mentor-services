require "rails_helper"

RSpec.describe AcademicYearDecorator do
  describe "#display_name" do
    let(:current_academic_year) { Placements::AcademicYear.current }

    context "when the academic year is the current academic year" do
      let(:decorated_academic_year) { current_academic_year.decorate }

      it "returns the academic year name with 'This academic year'" do
        expect(decorated_academic_year.display_name).to eq("This academic year (#{current_academic_year.name})")
      end
    end

    context "when the academic year is the next academic year" do
      let(:next_academic_year) { current_academic_year.next }
      let(:decorated_academic_year) { next_academic_year.decorate }

      it "returns the academic year name with 'Next academic year'" do
        expect(decorated_academic_year.display_name).to eq("Next academic year (#{next_academic_year.name})")
      end
    end

    context "when the academic year is the previous academic year" do
      let(:previous_academic_year) { current_academic_year.previous }
      let(:decorated_academic_year) { previous_academic_year.decorate }

      it "returns the academic year name with 'Previous academic year'" do
        expect(decorated_academic_year.display_name).to eq("Previous academic year (#{previous_academic_year.name})")
      end
    end
  end
end
