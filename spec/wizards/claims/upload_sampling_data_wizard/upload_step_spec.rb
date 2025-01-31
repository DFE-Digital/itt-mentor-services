require "rails_helper"

RSpec.describe Claims::UploadSamplingDataWizard::UploadStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadSamplingDataWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:paid_claims).and_return(Claims::Claim.paid)
    end
  end
  let(:paid_claims) { [create(:claim, :submitted, status: :paid, reference: 11_111_111)] }
  let(:attributes) { nil }

  describe "attributes" do
    it {
      expect(step).to have_attributes(csv_upload: nil,
                                      csv_content: nil,
                                      file_name: nil,
                                      claim_ids: [],
                                      invalid_claim_rows: [],
                                      missing_sample_reason_rows: [])
    }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:paid_claims).to(:wizard) }
  end

  describe "validations" do
    describe "#csv_upload" do
      context "when the csv_content is blank" do
        it { is_expected.to validate_presence_of(:csv_upload) }
      end

      context "when the csv_content is present" do
        let(:csv_content) { "claim_reference,sample_reason\r\n11111111,ABCD" }
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
          let(:paid_claims) { [create(:claim, :submitted, status: :paid, reference: 11_111_111)] }
          let(:attributes) { { csv_upload: valid_file } }
          let(:valid_file) do
            ActionDispatch::Http::UploadedFile.new({
              filename: "valid.csv",
              type: "text/csv",
              tempfile: File.open("spec/fixtures/claims/sampling/example_sampling_upload.csv"),
            })
          end

          before { paid_claims }

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
            "sampling_reason\r\n"
          end
          let(:attributes) { { csv_content: } }

          it "returns errors for missing headers" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:csv_upload]).to include(
              "Your file needs a column called ‘claim_reference’ and ‘sample_reason’.",
            )
            expect(step.errors.messages[:csv_upload]).to include(
              "Right now it has columns called ‘sampling_reason’.",
            )
          end
        end
      end
    end

    describe "#csv_inputs_valid?" do
      subject(:csv_inputs_valid) { step.csv_inputs_valid? }

      context "when the csv_content is blank" do
        it "returns true" do
          expect(csv_inputs_valid).to be(true)
        end
      end

      context "when csv_content contains invalid references" do
        let(:csv_content) do
          "claim_reference,sample_reason\r\n" \
          "11111111,Random auditing"
        end
        let(:attributes) { { csv_content: } }

        before { create(:claim, :submitted, status: :paid, reference: 22_222_222) }

        it "returns false and assigns the csv row to the 'invalid_claim_rows' attribute" do
          expect(csv_inputs_valid).to be(false)
          expect(step.invalid_claim_rows).to contain_exactly(0)
        end
      end

      context "when csv_content contains claims not with the status 'paid" do
        let(:csv_content) do
          "claim_reference,sampling_reason\r\n" \
          "11111111,Large provider"
        end
        let(:attributes) { { csv_content: } }

        before { create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111) }

        it "returns false and assigns the csv row to the 'invalid_claim_rows' attribute" do
          expect(csv_inputs_valid).to be(false)
          expect(step.invalid_claim_rows).to contain_exactly(0)
        end
      end

      context "when the csv_content does not contain a sample reason" do
        let(:csv_content) do
          "claim_reference,sample_reason\r\n" \
          "33333333,"
        end
        let(:attributes) { { csv_content: } }

        before { create(:claim, :submitted, status: :paid, sampling_reason: nil, reference: 33_333_333) }

        it "returns false and assigns the reference to the 'missing_sample_reason_rows' attribute" do
          expect(csv_inputs_valid).to be(false)
          expect(step.missing_sample_reason_rows).to contain_exactly(0)
        end
      end

      context "when the csv_content contains valid claim references and all necessary attributes" do
        let(:csv_content) do
          "claim_reference,sample_reason\r\n" \
          "11111111,Routine audit"
        end
        let(:attributes) { { csv_content: } }

        before { create(:claim, :submitted, status: :paid, sampling_reason: "Routine audit", reference: 11_111_111) }

        it "returns true" do
          expect(csv_inputs_valid).to be(true)
        end
      end
    end

    describe "#process_csv" do
      let(:paid_claims) { [create(:claim, :submitted, status: :paid, reference: 11_111_111)] }
      let(:submitted_claim) { create(:claim, :submitted, reference: 22_222_222) }
      let(:attributes) { { csv_upload: valid_file } }
      let(:valid_file) do
        ActionDispatch::Http::UploadedFile.new({
          filename: "valid.csv",
          type: "text/csv",
          tempfile: File.open("spec/fixtures/claims/sampling/example_sampling_upload.csv"),
        })
      end

      before { paid_claims }

      it "reads a given CSV and assigns the content to the csv_content attribute,
        and assigns the associated claim IDs to the claim_ids attribute" do
        expect(step.csv_content).to eq("claim_reference,sample_reason\n11111111,Some Reason\n")
      end
    end
  end

  describe "#csv" do
    subject(:csv) { step.csv }

    let(:csv_content) do
      "claim_reference,sample_reason\r\n" \
      "11111111,Some reason\r\n" \
      "11111111,Another reason\r\n" \
      "22222222,A reason\r\n" \
      ""
    end
    let(:attributes) { { csv_content: } }

    it "converts the csv content into a CSV record" do
      expect(csv).to be_a(CSV::Table)
      expect(csv.headers).to match_array(
        %w[claim_reference sample_reason],
      )
      expect(csv.count).to eq(3)

      expect(csv[0]).to be_a(CSV::Row)
      expect(csv[0].to_h).to eq({
        "claim_reference" => "11111111",
        "sample_reason" => "Some reason",
      })

      expect(csv[1]).to be_a(CSV::Row)
      expect(csv[1].to_h).to eq({
        "claim_reference" => "11111111",
        "sample_reason" => "Another reason",
      })

      expect(csv[2]).to be_a(CSV::Row)
      expect(csv[2].to_h).to eq({
        "claim_reference" => "22222222",
        "sample_reason" => "A reason",
      })
    end
  end
end
