RSpec.shared_examples "a mentor form" do
  before do
    stub_teaching_record_response(date_of_birth:, trn:)
    mentor
  end

  let!(:school) { create(:school) }
  let(:trn) { "1234567" }
  let(:date_of_birth) { "1991-01-22" }

  describe "validations" do
    context "when the form is valid" do
      it "returns valid" do
        form = described_class.new(
          "date_of_birth(3i)" => "22",
          "date_of_birth(2i)" => "1",
          "date_of_birth(1i)" => "1991",
          "trn" => trn,
          "school" => school,
        )
        expect(form.valid?).to eq(true)
      end
    end

    context "when trn is not set" do
      it "returns invalid", :aggregate_failures do
        form = described_class.new(school:)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:trn]).to include("Enter a teacher reference number (TRN)")
      end
    end

    context "when date_of_birth is not set" do
      let(:date_of_birth) { Struct.new(:day, :month, :year).new(nil, nil, nil).to_s }

      it "returns invalid", :aggregate_failures do
        form = described_class.new(trn:, school:)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:date_of_birth]).to include("Enter a date of birth")
      end
    end

    context "when date_of_birth is in future" do
      before { stub_teaching_record_response(date_of_birth: "#{year}-01-22", trn:) }

      let(:year) { Time.zone.today.year + 1 }

      it "returns invalid", :aggregate_failures do
        form = described_class.new(
          "date_of_birth(3i)" => "22",
          "date_of_birth(2i)" => "1",
          "date_of_birth(1i)" => year.to_s,
          "trn" => trn,
          "school" => school,
        )
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:date_of_birth]).to include("Date of birth must be in the past")
      end
    end
  end

  describe "#mentor" do
    it "returns an instance of a Placements::Mentor" do
      form = described_class.new(school:)
      expect(form.mentor).to be_a mentor_class
    end

    context "when mentor already exists" do
      let(:date_of_birth) { Struct.new(:day, :month, :year).new(nil, nil, nil).to_s }

      it "returns the existing mentor" do
        form = described_class.new(trn: mentor.trn, school:)
        expect(form.mentor).to eq(mentor)
      end
    end
  end

  describe "persist" do
    context "when the mentor doesn't exist" do
      let(:trn) { "2345678" }

      before { stub_teaching_record_response(date_of_birth:, trn: "1234567") }

      it "creates a new mentor and membership" do
        form = described_class.new(
          "date_of_birth(3i)" => "22",
          "date_of_birth(2i)" => "1",
          "date_of_birth(1i)" => "1991",
          "trn" => "1234567",
          "school" => school,
          "first_name" => "Jane",
          "last_name" => "Doe",
        )

        expect {
          form.persist
        }.to change(mentor_class, :count).by(1)
        .and change(mentor_membership_class, :count).by(1)
      end
    end

    context "when the mentor does exist" do
      let(:date_of_birth) { Struct.new(:day, :month, :year).new(nil, nil, nil).to_s }

      it "creates a new mentor membership" do
        form = described_class.new(trn: mentor.trn, first_name: mentor.first_name, last_name: mentor.last_name, school:)

        expect {
          form.persist
        }.to change { mentor.mentor_memberships.count }.by(1)
      end
    end
  end

  describe "#as_form_params" do
    it "returns a hash of form params" do
      form = described_class.new(
        "date_of_birth(3i)" => "14",
        "date_of_birth(2i)" => "1",
        "date_of_birth(1i)" => "1999",
        "trn" => trn,
        "school" => school,
      )
      expect(form.as_form_params).to eq(form_params_key => { "date_of_birth(1i)" => 1999, "date_of_birth(2i)" => 1, "date_of_birth(3i)" => 14, "trn" => "1234567" })
    end
  end

  def stub_teaching_record_response(trn:, date_of_birth: "1991-01-22")
    allow(TeachingRecord::GetTeacher).to receive(:call).with(trn:, date_of_birth:).and_return(
      { "trn" => "1234567",
        "firstName" => "Judith",
        "lastName" => "Chicken",
        "dateOfBirth" => date_of_birth },
    )
  end
end
