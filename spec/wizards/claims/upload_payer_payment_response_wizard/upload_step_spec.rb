require "rails_helper"

RSpec.describe Claims::UploadPayerPaymentResponseWizard::UploadStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadPayerPaymentResponseWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:payment_in_progress_claims).and_return(Claims::Claim.payment_in_progress)
    end
  end
  let(:attributes) { nil }

  describe "attributes" do
    it {
      expect(step).to have_attributes(
        csv_upload: nil,
        csv_content: nil,
        file_name: nil,
        invalid_claim_rows: [],
        invalid_claim_status_rows: [],
        invalid_claim_unpaid_reason_rows: [],
        invalid_claim_paid_to_la_rows: [],
        invalid_claim_date_paid_rows: [],
      )
    }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:payment_in_progress_claims).to(:wizard) }
  end

  describe "validations" do
    describe "#csv_upload" do
      context "when the csv_content is blank" do
        it { is_expected.to validate_presence_of(:csv_upload) }
      end

      context "when the csv_content is present" do
        let(:csv_content) do
          "claim_reference,claim_status,claim_unpaid_reason,claim_paid_to_la,claim_date_paid\r\n" \
          "11111111,paid,,no,2026-09-21\r\n" \
          "22222222,unpaid,Some reason,,"
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
          let(:clawback_in_progress_claim_1) do
            create(:claim, :payment_in_progress, reference: 11_111_111)
          end
          let(:clawback_in_progress_claim_2) do
            create(:claim, :payment_in_progress, reference: 22_222_222)
          end
          let(:attributes) { { csv_upload: valid_file } }
          let(:valid_file) do
            ActionDispatch::Http::UploadedFile.new({
              filename: "valid.csv",
              type: "text/csv",
              tempfile: File.open(
                "spec/fixtures/claims/payment/example_payer_response.csv",
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
              "Your file needs a column called ‘claim_reference’, ‘claim_status’, ‘claim_unpaid_reason’, " \
              "‘claim_paid_to_la’, and ‘claim_date_paid’.",
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

    let(:attributes) { { csv_content: } }

    before { create(:claim, :payment_in_progress, reference: 11_111_111) }

    context "when a paid row is missing claim_paid_to_la" do
      let(:csv_content) do
        "claim_reference,claim_status,claim_unpaid_reason,claim_paid_to_la,claim_date_paid\r\n" \
        "11111111,paid,,,2026-09-21"
      end

      it "records the row as invalid" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_claim_paid_to_la_rows).to contain_exactly(0)
      end
    end

    context "when a paid row has an unparseable claim_date_paid" do
      let(:csv_content) do
        "claim_reference,claim_status,claim_unpaid_reason,claim_paid_to_la,claim_date_paid\r\n" \
        "11111111,paid,,yes,not a date"
      end

      it "records the row as invalid" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_claim_date_paid_rows).to contain_exactly(0)
      end
    end

    context "when an unpaid row leaves the payment details blank" do
      let(:csv_content) do
        "claim_reference,claim_status,claim_unpaid_reason,claim_paid_to_la,claim_date_paid\r\n" \
        "11111111,unpaid,Some reason,,"
      end

      it "does not record the row as invalid" do
        expect(csv_inputs_valid).to be(true)
      end
    end
  end

  describe "#paid_to_la_for" do
    let(:attributes) { { csv_content: } }
    let(:csv_content) do
      "claim_reference,claim_status,claim_unpaid_reason,claim_paid_to_la,claim_date_paid\r\n" \
      "11111111,paid,,Yes,2026-09-21\r\n" \
      "22222222,paid,,no,2026-09-21\r\n" \
      "33333333,unpaid,Some reason,,"
    end

    it "parses the column into a boolean, or nil when absent" do
      expect(step.csv.map { |row| step.paid_to_la_for(row) }).to eq([true, false, nil])
    end
  end

  describe "#date_paid_for" do
    let(:attributes) { { csv_content: } }
    let(:csv_content) do
      "claim_reference,claim_status,claim_unpaid_reason,claim_paid_to_la,claim_date_paid\r\n" \
      "11111111,paid,,yes,2026-09-21\r\n" \
      "22222222,paid,,no,not a date\r\n" \
      "33333333,paid,,no,2026-13-45\r\n" \
      "44444444,unpaid,Some reason,,"
    end

    it "parses the column into a time, or nil when unparseable, out of range or absent" do
      expect(step.csv.map { |row| step.date_paid_for(row) }).to eq(
        [Time.zone.parse("2026-09-21"), nil, nil, nil],
      )
    end
  end
end
