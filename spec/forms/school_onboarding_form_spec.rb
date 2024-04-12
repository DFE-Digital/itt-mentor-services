require "rails_helper"

describe SchoolOnboardingForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:service) }
    it { is_expected.to validate_inclusion_of(:service).in_array(%i[placements claims]) }

    context "when id is not present" do
      it "returns invalid" do
        form = described_class.new(id: nil, service: :placements)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:id]).to include("Enter a school name, URN or postcode")
      end
    end

    context "when id is not present and javascript is disabled" do
      it "returns invalid" do
        form = described_class.new(id: nil, service: :placements, javascript_disabled: true)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:id]).to include("Select a school")
      end
    end

    context "when given an id not associated with a school" do
      it "returns invalid" do
        form = described_class.new(id: "random", service: :placements)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:id]).to include("Enter a school name, URN or postcode")
      end
    end

    context "when given an id for a school already onboarded onto the given service" do
      it "returns invalid" do
        school = create(:school, :placements)
        form = described_class.new(id: school.id, service: :placements)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:id]).to include("#{school.name} has already been added. Try another school")
      end
    end

    context "when given an id for a school not onboarded onto the given service" do
      it "returns valid" do
        school = create(:school, :claims)
        form = described_class.new(id: school.id, service: :placements)
        expect(form.valid?).to eq(true)
      end
    end
  end

  describe "delegations" do
    describe "#name" do
      context "when school is nil" do
        it "returns nil" do
          form = described_class.new
          expect(form.name).to eq(nil)
        end
      end

      context "when school exists" do
        it "returns then name of the school" do
          school = create(:school, name: "School 1")
          form = described_class.new(id: school.id)
          expect(form.name).to eq("School 1")
        end
      end
    end
  end

  describe "#school" do
    context "when given the id of an existing school" do
      it "returns the school associated with that id" do
        school = create(:school)
        expect(described_class.new(id: school.id).school).to eq(school)
      end
    end

    context "when given an id not associated with a school" do
      it "returns nil" do
        expect(described_class.new(id: "random").school).to eq(nil)
      end
    end
  end

  describe "save!" do
    it "enables the boolean flag for the given service" do
      school = create(:school)
      onboarding = expect do
        described_class.new(id: school.id, service: :placements).save!
        school.reload
      end
      onboarding.to change(school, :placements_service).from(false).to(true)
    end
  end

  describe "as_form_params" do
    it "returns form params" do
      expect(described_class.new(
        id: "1234",
        javascript_disabled: true,
        service: "claims",
      ).as_form_params).to eq({
        "school" =>
          {
            id: "1234",
            javascript_disabled: true,
            service: "claims",
          },
      })
    end
  end
end
