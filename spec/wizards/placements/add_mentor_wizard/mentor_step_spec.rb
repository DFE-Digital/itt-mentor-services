require "rails_helper"

RSpec.describe Placements::AddMentorWizard::MentorStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mentor_class) { Placements::Mentor }
  let(:mentor_membership_class) { Placements::MentorMembership }
  let!(:school) { create(:school) }
  let(:attributes) { nil }

  let(:mock_wizard) do
    instance_double(Placements::AddMentorWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  describe "attributes" do
    it { is_expected.to have_attributes(trn: nil, year: nil, month: nil, day: nil) }
  end

  describe "validations" do
    context "when trn is not set" do
      it "returns invalid", :aggregate_failures do
        expect(step.valid?).to be(false)
        expect(step.errors.messages[:trn]).to include("Enter a teacher reference number (TRN)")
      end
    end

    context "when date_of_birth is not set" do
      let(:date_of_birth) { Struct.new(:day, :month, :year).new(nil, nil, nil).to_s }
      let(:trn) { "1234567" }
      let(:attributes) { { trn: } }

      before { stub_teaching_record_response(date_of_birth:, trn:) }

      it "returns invalid", :aggregate_failures do
        expect(step.valid?).to be(false)
        expect(step.errors.messages[:date_of_birth]).to include("Enter a date of birth")
      end
    end

    context "when date_of_birth is in future" do
      let(:trn) { "1234567" }
      let(:year) { Time.zone.today.year + 1 }
      let(:attributes) do
        { trn:,
          "date_of_birth(3i)" => "22",
          "date_of_birth(2i)" => "01",
          "date_of_birth(1i)" => year }
      end

      before { stub_teaching_record_response(date_of_birth: "#{year}-01-22", trn:) }

      it "returns invalid", :aggregate_failures do
        expect(step.valid?).to be(false)
        expect(step.errors.messages[:date_of_birth]).to include("Date of birth must be in the past")
      end
    end
  end

  describe "#mentor" do
    it "returns an instance of a Placements::Mentor" do
      expect(step.mentor).to be_a mentor_class
    end

    context "when mentor already exists" do
      let(:mentor) { create(:placements_mentor) }
      let(:date_of_birth) { "1991-01-22" }
      let(:trn) { mentor.trn }
      let(:attributes) do
        { trn:,
          "date_of_birth(3i)" => "22",
          "date_of_birth(2i)" => "01",
          "date_of_birth(1i)" => "1991" }
      end

      before { stub_teaching_record_response(date_of_birth:, trn:) }

      it "returns the existing mentor" do
        expect(step.mentor).to eq(mentor)
      end
    end
  end

  describe "#date_of_birth" do
    let(:trn) { "1234567" }
    let(:year) { 1991 }
    let(:month) { 1 }
    let(:day) { 22 }
    let(:attributes) do
      { trn:,
        "date_of_birth(3i)" => day,
        "date_of_birth(2i)" => month,
        "date_of_birth(1i)" => year }
    end

    it "returns a date object" do
      expect(step.date_of_birth).to eq(Date.new(year, month, day))
    end

    context "when date_of_birth is invalid" do
      let(:year) { 1991 }
      let(:month) { 1 }
      let(:day) { nil }

      it "returns a struct" do
        expect(step.date_of_birth).to have_attributes(year:, month:, day:)
      end
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
