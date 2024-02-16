require "rails_helper"

RSpec.describe MentorBuilder do
  context "with invalid trn provided" do
    let(:trn) { "ab" }

    it "returns mentor object with error on trn" do
      mentor = described_class.call(trn:)
      expect(mentor.class).to eq(Mentor)
      expect(mentor.errors[:trn]).to include "Enter a valid teacher reference number (TRN)"
    end
  end

  context "with empty trn provided" do
    let(:trn) { nil }

    it "returns mentor object with error on trn" do
      mentor = described_class.call(trn:)
      expect(mentor.class).to eq(Mentor)
      expect(mentor.errors[:trn]).to include "Enter a teacher reference number (TRN)"
    end
  end

  context "when mentor with trn already exists" do
    let(:existing_mentor) { create(:mentor) }
    let(:trn) { existing_mentor.trn }

    it "returns existing mentor" do
      mentor = described_class.call(trn:)
      expect(mentor).to eq existing_mentor
    end
  end

  context "when mentor does not exist and valid trn is provided" do
    let(:trn) { "1234567" }

    before "fetches teacher record from teaching record service" do
      allow(TeachingRecord::GetTeacher).to receive(:call).with(trn:).once.and_return(teacher_object)
    end

    it "returns initialized mentor record without errors" do
      mentor = described_class.call(trn:)
      expect(mentor.trn).to eq trn
      expect(mentor.first_name).to eq teacher_object["firstName"]
      expect(mentor.last_name).to eq teacher_object["lastName"]
      expect(mentor.persisted?).to eq false
      expect(mentor.errors.none?).to eq true
    end
  end

  context "with valid trn and first_name or last_name args given" do
    let(:trn) { "0987654" }
    let(:first_name) { "First Name" }
    let(:last_name) { "Last Name" }

    it "returns initialized mentor record with first and last name" do
      mentor = described_class.call(trn:, first_name:, last_name:)
      expect(mentor.trn).to eq trn
      expect(mentor.first_name).to eq first_name
      expect(mentor.last_name).to eq last_name
      expect(mentor.persisted?).to eq false
      expect(mentor.errors.none?).to eq true
    end
  end

  def teacher_object
    { "trn" => "1234554",
      "firstName" => "Elizabeth",
      "middleName" => "Elaine",
      "lastName" => "Milner-Lee" }
  end
end
