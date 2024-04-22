require "rails_helper"

describe Placements::PartnershipForm, type: :model do
  let!(:school) { create(:placements_school) }
  let!(:provider) { create(:placements_provider) }

  describe "validations" do
    context "when the form is valid" do
      it "returns valid" do
        form = described_class.new(
          provider_id: provider.id,
          school_id: school.id,
        )

        expect(form.valid?).to eq(true)
      end
    end

    context "when given no school id" do
      context "when javascript is enabled" do
        it "returns invalid" do
          form = described_class.new(
            provider_id: provider.id,
            school_id: nil,
            javascript_disabled: false,
            form_input: :school_id,
          )

          expect(form.valid?).to eq(false)
          expect(form.errors.messages[:school_id]).to include("Enter a school name, URN or postcode")
        end
      end

      context "when javascript is disabled" do
        it "returns invalid" do
          form = described_class.new(
            provider_id: provider.id,
            school_id: nil,
            javascript_disabled: true,
            form_input: :school_id,
          )

          expect(form.valid?).to eq(false)
          expect(form.errors.messages[:school_id]).to include("Select a school")
        end
      end
    end

    context "when given no provider id" do
      context "when javascript is enabled" do
        it "returns invalid" do
          form = described_class.new(
            provider_id: nil,
            school_id: school.id,
            javascript_disabled: false,
            form_input: :provider_id,
          )

          expect(form.valid?).to eq(false)
          expect(form.errors.messages[:provider_id]).to include("Enter a provider name, UKPRN, URN or postcode")
        end
      end

      context "when javascript is disabled" do
        it "returns invalid" do
          form = described_class.new(
            provider_id: nil,
            school_id: school.id,
            javascript_disabled: true,
            form_input: :provider_id,
          )

          expect(form.valid?).to eq(false)
          expect(form.errors.messages[:provider_id]).to include("Select a provider")
        end
      end
    end

    context "when given an id not associated with a placements provider" do
      it "returns invalid" do
        form = described_class.new(
          provider_id: "1234",
          school_id: school.id,
        )

        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:provider_id]).to include("Enter a provider name, UKPRN, URN or postcode")
      end
    end

    context "when given an id not associated with a placements school" do
      it "returns invalid" do
        form = described_class.new(
          provider_id: provider.id,
          school_id: "1234",
        )

        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:school_id]).to include("Enter a school name, URN or postcode")
      end
    end

    context "when a partnership between a school and provider already exists" do
      before do
        create(:placements_partnership, school:, provider:)
      end

      context "when form input is school_id" do
        it "returns invalid" do
          form = described_class.new(
            provider_id: provider.id,
            school_id: school.id,
            form_input: :school_id,
          )

          expect(form.valid?).to eq(false)
          expect(form.errors.messages[:school_id]).to include("#{school.name} has already been added. Try another school")
        end
      end

      context "when form input is provider_id" do
        it "returns invalid" do
          form = described_class.new(
            provider_id: provider.id,
            school_id: school.id,
            form_input: :provider_id,
          )

          expect(form.valid?).to eq(false)
          expect(form.errors.messages[:provider_id]).to include("#{provider.name} has already been added. Try another provider")
        end
      end
    end
  end

  describe "#school" do
    context "when given the id of an existing placement school" do
      it "returns the placement school associated with that id" do
        school = create(:school)
        expect(described_class.new(school_id: school.id).school).to eq(school)
      end
    end

    context "when given an id not associated with a school" do
      it "returns nil" do
        expect(described_class.new(school_id: "random").school).to eq(nil)
      end
    end
  end

  describe "#provider" do
    context "when given the id of an existing placement provider" do
      it "returns the placement school associated with that id" do
        provider = create(:provider)
        expect(described_class.new(provider_id: provider.id).provider).to eq(provider)
      end
    end

    context "when given an id not associated with a school" do
      it "returns nil" do
        expect(described_class.new(provider_id: "random").provider).to eq(nil)
      end
    end
  end

  describe "#as_form_params" do
    it "returns form params" do
      form = described_class.new(
        provider_id: provider.id,
        school_id: school.id,
        form_input: :provider_id,
      )

      expect(form.as_form_params).to eq(
        {
          "partnership" => {
            school_id: school.id,
            provider_id: provider.id,
          },
        },
      )
    end
  end

  describe "#persist" do
    context "when a partnership between then given school and provider does not exists" do
      it "creates a partnership between the given school and provider" do
        form = described_class.new(
          provider_id: provider.id,
          school_id: school.id,
        )

        expect { form.persist }.to change(Placements::Partnership, :count).by(1)
      end
    end

    context "when a partnership between then given school and provider already exists" do
      it "returns an error" do
        create(:placements_partnership, school:, provider:)
        form = described_class.new(
          provider_id: provider.id,
          school_id: school.id,
        )

        expect { form.persist }.to raise_error(
          ActiveRecord::RecordInvalid,
          "Validation failed: School has already been taken",
        )
      end
    end
  end
end
