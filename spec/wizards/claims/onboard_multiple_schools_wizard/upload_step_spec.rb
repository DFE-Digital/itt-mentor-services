require "rails_helper"

RSpec.describe Claims::OnboardMultipleSchoolsWizard::UploadStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::OnboardMultipleSchoolsWizard)
  end
  let(:attributes) { nil }

  describe "attributes" do
    it {
      expect(step).to have_attributes(
        csv_upload: nil,
        csv_content: nil,
        file_name: nil,
        invalid_school_name_rows: [],
        invalid_school_urn_rows: [],
      )
    }
  end

  describe "validations" do
    describe "#csv_upload" do
      context "when the csv_content is blank" do
        it { is_expected.to validate_presence_of(:csv_upload) }
      end

      context "when the csv_content is present" do
        let(:csv_content) do
          "name,urn\r\n" \
          "London School,111111\r\n"
        end
        let(:attributes) { { csv_content: } }

        it { is_expected.not_to validate_presence_of(:csv_upload) }
      end
    end

    describe "#validate_csv_file" do
      context "when the csv_upload is present" do
        context "when the csv_upload is not a CSV" do
          let(:attributes) { { csv_upload: invalid_file } }
          let(:invalid_file) do
            ActionDispatch::Http::UploadedFile.new({
              filename: "invalid.jpg",
              type: "image/jpeg",
              tempfile: Tempfile.new("invalid.jpg"),
            })
          end

          it "validates that the file is the incorrect format" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:csv_upload]).to include("The selected file must be a CSV")
          end
        end

        context "when the csv_upload is a CSV file" do
          let(:attributes) { { csv_upload: valid_file } }
          let(:valid_file) do
            ActionDispatch::Http::UploadedFile.new({
              filename: "valid.csv",
              type: "text/csv",
              tempfile: File.open(
                "spec/fixtures/claims/school/onboarding_schools.csv",
              ),
            })
          end

          it "validates that the file is the correct format" do
            expect(step.valid?).to be(true)
          end
        end
      end
    end

    describe "#validate_csv_headers" do
      context "when csv_content is present" do
        context "when the csv content is missing valid headers" do
          let(:csv_content) do
            "something_random\r\n" \
            "blah"
          end
          let(:attributes) { { csv_content: } }

          it "returns errors for missing headers" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:csv_upload]).to include(
              "Your file needs a column called ‘name’ and ‘urn’.",
            )
            expect(step.errors.messages[:csv_upload]).to include(
              "Right now it has columns called ‘something_random’.",
            )
          end
        end
      end
    end
  end

  describe "#csv_inputs_valid?" do
    subject(:csv_inputs_valid) { step.csv_inputs_valid? }

    before { create(:school, name: "London School", urn: "111111") }

    context "when the csv_content is blank" do
      it "returns true" do
        expect(csv_inputs_valid).to be(true)
      end
    end

    context "when csv_content contains invalid school name" do
      let(:csv_content) do
        "name,urn\r\n" \
        "Random School,111111\r\n"
      end
      let(:attributes) { { csv_content: } }

      it "returns false and assigns the csv row to the 'invalid_school_name_rows' attribute" do
        pending "Validation temp removed"

        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_school_name_rows).to contain_exactly(0)
      end
    end

    context "when csv_content contains invalid school urn" do
      let(:csv_content) do
        "name,urn\r\n" \
        "London School,222222\r\n"
      end
      let(:attributes) { { csv_content: } }

      it "returns false and assigns the csv row to the 'invalid_school_urn_rows' attribute" do
        pending "Validation temp removed"

        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_school_urn_rows).to contain_exactly(0)
      end
    end

    context "when the csv_content contains valid urn and all necessary valid attributes" do
      let(:csv_content) do
        "name,urn\r\n" \
        "London School,111111\r\n"
      end
      let(:attributes) { { csv_content: } }

      it "returns true" do
        expect(csv_inputs_valid).to be(true)
      end
    end
  end

  describe "#process_csv" do
    let(:london_school) { create(:school, name: "London School", urn: "111111") }
    let(:guildford_school) { create(:school, name: "Guildford School", urn: "222222") }
    let(:attributes) { { csv_upload: valid_file } }
    let(:valid_file) do
      ActionDispatch::Http::UploadedFile.new({
        filename: "valid.csv",
        type: "text/csv",
        tempfile: File.open(
          "spec/fixtures/claims/school/onboarding_schools.csv",
        ),
      })
    end

    before do
      london_school
      guildford_school
    end

    it "reads a given CSV and assigns the content to the csv_content attribute" do
      expect(step.csv_content).to eq(
        "name,urn\n" \
        "London School,111111\n" \
        "Guildford School,222222\n" \
        ",\n",
      )
    end
  end

  describe "#csv" do
    subject(:csv) { step.csv }

    let(:csv_content) do
      "name,urn\n" \
      "London School,111111\n" \
      "Guildford School,222222\n" \
      ""
    end
    let(:attributes) { { csv_content: } }

    it "converts the csv content into a CSV record" do
      expect(csv).to be_a(CSV::Table)
      expect(csv.headers).to match_array(
        %w[name urn],
      )
      expect(csv.count).to eq(2)

      expect(csv[0]).to be_a(CSV::Row)
      expect(csv[0].to_h).to eq({
        "name" => "London School",
        "urn" => "111111",
      })

      expect(csv[1]).to be_a(CSV::Row)
      expect(csv[1].to_h).to eq({
        "name" => "Guildford School",
        "urn" => "222222",
      })
    end
  end
end
