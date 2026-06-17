require "rails_helper"

RSpec.describe Claims::OnboardProvidersWizard::UploadStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) { instance_double(Claims::OnboardProvidersWizard) }
  let(:attributes) { nil }

  describe "attributes" do
    it {
      expect(step).to have_attributes(
        csv_upload: nil,
        csv_content: nil,
        file_name: nil,
        missing_first_name_rows: [],
        missing_last_name_rows: [],
        invalid_email_rows: [],
        invalid_provider_code_rows: [],
      )
    }
  end

  describe "validations" do
    describe "#csv_upload" do
      context "when csv_content is blank" do
        it { is_expected.to validate_presence_of(:csv_upload) }
      end

      context "when csv_content is present" do
        let(:csv_content) do
          "provider_code,first_name,last_name,email\r\n" \
          "ABC,John,Smith,john_smith@example.com"
        end
        let(:attributes) { { csv_content: } }

        it { is_expected.not_to validate_presence_of(:csv_upload) }
      end
    end

    describe "#validate_csv_headers" do
      context "when csv_content is missing required headers" do
        let(:csv_content) do
          "something_random\r\n" \
          "blah"
        end
        let(:attributes) { { csv_content: } }

        it "returns errors for missing headers" do
          expect(step.valid?).to be(false)
          expect(step.errors.messages[:csv_upload]).to include(
            "Your file needs a column called 'email', 'provider_code', 'first_name', and 'last_name'.",
          )
          expect(step.errors.messages[:csv_upload]).to include(
            "Right now it has columns called 'something_random'.",
          )
        end
      end
    end

    describe "#validate_csv_file" do
      context "when csv_upload is not a CSV" do
        let(:attributes) { { csv_upload: invalid_file } }
        let(:invalid_file) do
          ActionDispatch::Http::UploadedFile.new({
            filename: "invalid.jpg",
            type: "image/jpeg",
            tempfile: Tempfile.new("invalid.jpg"),
          })
        end

        it "adds an invalid file error" do
          expect(step.valid?).to be(false)
          expect(step.errors.messages[:csv_upload]).to include("The selected file must be a CSV")
        end

        it "does not process and persist file content" do
          expect(step.csv_content).to be_nil
          expect(step.file_name).to be_nil
          expect(step.csv_upload).to eq(invalid_file)
        end
      end

      context "when csv_upload is a CSV" do
        let(:attributes) { { csv_upload: valid_file } }
        let(:valid_file) do
          ActionDispatch::Http::UploadedFile.new({
            filename: "valid.csv",
            type: "text/csv",
            tempfile: File.open(
              "spec/fixtures/claims/provider_user/upload_provider_users.csv",
            ),
          })
        end

        it "is valid" do
          expect(step.valid?).to be(true)
        end
      end
    end
  end

  describe "#csv_inputs_valid?" do
    subject(:csv_inputs_valid) { step.csv_inputs_valid? }

    before { create(:claims_provider, name: "London Provider", code: "ABC") }

    context "when csv_content is blank" do
      it "returns true" do
        expect(csv_inputs_valid).to be(true)
      end
    end

    context "when csv_content contains invalid provider code" do
      let(:csv_content) do
        "provider_code,first_name,last_name,email\r\n" \
        "ZZZ,John,Smith,john_smith@example.com"
      end
      let(:attributes) { { csv_content: } }

      it "returns false and assigns invalid provider code rows" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_provider_code_rows).to contain_exactly(0)
      end
    end

    context "when csv_content contains invalid email" do
      let(:csv_content) do
        "provider_code,first_name,last_name,email\r\n" \
        "ABC,John,Smith,invalid_email"
      end
      let(:attributes) { { csv_content: } }

      it "returns false and assigns invalid email rows" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_email_rows).to contain_exactly(0)
      end
    end

    context "when csv_content contains missing first_name" do
      let(:csv_content) do
        "provider_code,first_name,last_name,email\r\n" \
        "ABC,James,Samson,test@sample.com\r\n" \
        "ABC,,Smith,test@sample.com"
      end
      let(:attributes) { { csv_content: } }

      it "returns false and assigns missing first_name rows" do
        expect(csv_inputs_valid).to be(false)
        expect(step.missing_first_name_rows).to contain_exactly(1)
      end
    end

    context "when csv_content contains missing last_name" do
      let(:csv_content) do
        "provider_code,first_name,last_name,email\r\n" \
        "ABC,James,,test@sample.com\r\n" \
        "ABC,James,Samson,test@sample.com"
      end
      let(:attributes) { { csv_content: } }

      it "returns false and assigns missing last_name rows" do
        expect(csv_inputs_valid).to be(false)
        expect(step.missing_last_name_rows).to contain_exactly(0)
      end
    end

    context "when csv_content is valid" do
      let(:csv_content) do
        "provider_code,first_name,last_name,email\r\n" \
        "ABC,John,Smith,john_smith@example.com\r\n" \
        ",,,,"
      end
      let(:attributes) { { csv_content: } }

      it "returns true" do
        expect(csv_inputs_valid).to be(true)
      end
    end
  end

  describe "#process_csv" do
    let(:attributes) { { csv_upload: valid_file } }
    let(:valid_file) do
      ActionDispatch::Http::UploadedFile.new({
        filename: "valid.csv",
        type: "text/csv",
        tempfile: File.open(
          "spec/fixtures/claims/provider_user/upload_provider_users.csv",
        ),
      })
    end

    it "reads a given CSV and assigns the content to csv_content" do
      expect(step.csv_content).to eq(
        "provider_name,provider_code,first_name,last_name,email\n" \
        "London Provider,ABC,Joe,Bloggs,joe_bloggs@example.com\n" \
        "Guildford Provider,XYZ,Sue,Doe,sue_doe@example.com\n" \
        ",,,,\n",
      )
    end
  end

  describe "#csv" do
    subject(:csv) { step.csv }

    let(:csv_content) do
      "provider_name,provider_code,first_name,last_name,email\n" \
      "London Provider,ABC,Joe,Bloggs,joe_bloggs@example.com\n" \
      "Guildford Provider,XYZ,Sue,Doe,sue_doe@example.com\n"
    end
    let(:attributes) { { csv_content: } }

    it "converts csv content into a CSV record" do
      expect(csv).to be_a(CSV::Table)
      expect(csv.headers).to match_array(
        %w[provider_name provider_code first_name last_name email],
      )
      expect(csv.count).to eq(2)

      expect(csv[0].to_h).to eq({
        "provider_name" => "London Provider",
        "provider_code" => "ABC",
        "first_name" => "Joe",
        "last_name" => "Bloggs",
        "email" => "joe_bloggs@example.com",
      })
    end
  end
end
