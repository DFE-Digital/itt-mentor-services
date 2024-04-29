require "rails_helper"

RSpec.describe Claims::MentorBuilder do
  it_behaves_like "a service object" do
    let(:params) { { trn: "1234567" } }
  end

  context "with invalid trn provided" do
    let(:trn) { "ab" }

    it "returns mentor object with error on trn" do
      mentor = described_class.call(trn:)
      expect(mentor.class).to eq(Claims::Mentor)
      expect(mentor.errors[:trn]).to include "Enter a valid teacher reference number (TRN)"
    end
  end

  context "with empty trn provided" do
    let(:trn) { nil }

    it "returns mentor object with error on trn" do
      mentor = described_class.call(trn:)
      expect(mentor.class).to eq(Claims::Mentor)
      expect(mentor.errors[:trn]).to include "Enter a teacher reference number (TRN)"
    end
  end

  context "with empty date of birth is provided" do
    let(:trn) { "1234567" }
    let(:date_of_birth) { nil }

    it "returns mentor object" do
      mentor = described_class.call(trn:, date_of_birth:)
      expect(mentor.class).to eq(Claims::Mentor)
    end
  end

  context "when mentor with trn already exists" do
    let(:existing_mentor) { create(:claims_mentor) }
    let(:trn) { existing_mentor.trn }

    it "returns existing mentor" do
      mentor = described_class.call(trn:)
      expect(mentor).to eq existing_mentor
    end
  end

  context "when mentor does not exist and valid trn is provided" do
    let(:trn) { "1234567" }
    let(:date_of_birth) { Date.new(1986, 11, 12) }

    before "fetches teacher record from teaching record service" do
      allow(TeachingRecord::GetTeacher).to receive(:call).with(trn:, date_of_birth: date_of_birth.to_s)
        .once.and_return(teacher_object)
    end

    it "returns initialized mentor record without errors" do
      mentor = described_class.call(trn:, date_of_birth:)
      expect(mentor.trn).to eq trn
      expect(mentor.first_name).to eq teacher_object["firstName"]
      expect(mentor.last_name).to eq teacher_object["lastName"]
      expect(mentor.persisted?).to eq false
      expect(mentor.errors.none?).to eq true
    end
  end

  context "when mentor does exist but dob doesn't match" do
    let(:existing_mentor) { create(:mentor, trn: "1234567") }
    let(:trn) { existing_mentor.trn }
    let(:date_of_birth) { Date.new(1999, 11, 12) }

    before "fetches teacher record from teaching record service" do
      allow(TeachingRecord::GetTeacher).to receive(:call).with(trn:, date_of_birth: date_of_birth.to_s)
        .once.and_return(teacher_object)
    end

    it "returns initialized mentor record without errors" do
      mentor = described_class.call(trn:, date_of_birth:)
      expect(mentor.trn).to eq trn
      expect(mentor.first_name).to eq teacher_object["firstName"]
      expect(mentor.last_name).to eq teacher_object["lastName"]
      expect(mentor.persisted?).to eq true
      expect(mentor.errors.none?).to eq true
    end
  end

  def teacher_object
    { "trn" => "1234554",
      "firstName" => "Elizabeth",
      "middleName" => "Elaine",
      "lastName" => "Milner-Lee",
      "dateOfBirth" => "1986-11-12" }
  end
end
