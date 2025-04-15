RSpec.shared_examples "an academic year assignable object" do
  describe "associations" do
    let(:selected_academic_year) { Placements::AcademicYear.current.next }
    let(:user) do
      described_class.create(
        first_name: "John",
        last_name: "Smith",
        email: "name@education.gov.uk",
        selected_academic_year:,
      )
    end

    # Due to before_validation callback on creation,
    # each association scenerio must be tested seperately.
    context "when the object has an selected academic year associated" do
      it "returns the associated academic year" do
        expect(user.selected_academic_year).to eq(selected_academic_year)
      end
    end

    context "when the object is updated to have no selected academic year associated" do
      it "returns an error" do
        user.selected_academic_year = nil
        expect(user.valid?).to be(false)
        expect(user.errors[:selected_academic_year]).to include("must exist")
      end
    end
  end

  describe "#assign_default_academic_year" do
    let(:next_academic_year) { Placements::AcademicYear.current.next }

    it "assigns the next academic year to new object on creation" do
      user = described_class.new(
        first_name: "John",
        last_name: "Smith",
        email: "name@education.gov.uk",
      )
      expect(user.selected_academic_year).to be_nil
      user.save!
      expect(user.reload.selected_academic_year).to eq(next_academic_year)
    end
  end
end
