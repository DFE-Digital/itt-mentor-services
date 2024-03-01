require "rails_helper"

describe Placements::MentorForm, type: :model do
  before { stub_teaching_record_response }

  let!(:school) { create(:school) }
  let!(:mentor) { create(:placements_mentor) }
  let(:trn) { "1234567" }

  describe "validations" do
    context "when the form is valid" do
      it "returns valid" do
        form = described_class.new(trn:, school:)
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
  end

  describe "#mentor" do
    it "returns an instance of a Placements::Mentor" do
      form = described_class.new(school:)
      expect(form.mentor).to be_a Placements::Mentor
    end

    context "when mentor already exists" do
      it "returns the existing mentor" do
        form = described_class.new(trn: mentor.trn, school:)
        expect(form.mentor).to eq(mentor)
      end
    end
  end

  describe "persist" do
    context "when the mentor doesn't exist" do
      let(:trn) { "2345678" }

      it "creates a new mentor and membership" do
        form = described_class.new(trn: "1234567", first_name: "Jane", last_name: "Doe", school:)

        expect {
          form.persist
        }.to change(Placements::Mentor, :count).by(1)
        .and change(Placements::MentorMembership, :count).by(1)
      end
    end

    context "when the mentor does exist" do
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
      form = described_class.new(trn:, school:)
      expect(form.as_form_params).to eq("placements_mentor_form" => { "trn" => "1234567" })
    end
  end

  def stub_teaching_record_response
    allow(TeachingRecord::GetTeacher).to receive(:call).with(trn:).and_return(
      status: 200,
      body: "{\"trn\":\"1234567\",\"firstName\":\"Judith\",\"middleName\":\"\",\"lastName\":\"Chicken\",\"dateOfBirth\":\"1991-01-22\",\"nationalInsuranceNumber\":\"B15J60R13\",\"email\":\"anonymous@anonymousdomain.org.net.co.uk\",\"qts\":null,\"eyts\":null}",
      headers: {},
    )
  end
end
