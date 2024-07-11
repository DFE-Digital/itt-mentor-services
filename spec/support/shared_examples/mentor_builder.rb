RSpec.shared_examples "a mentor builder" do
  it_behaves_like "a service object" do
    let(:params) { { trn: "1234567", date_of_birth: "1991-01-22" } }
  end

  context "with invalid trn provided" do
    let(:trn) { "ab" }
    let(:date_of_birth) { "1991-01-22" }

    it "returns mentor object with error on trn" do
      mentor = described_class.call(trn:, date_of_birth: Date.parse(date_of_birth))
      expect(mentor.class).to eq(mentor_class)
      expect(mentor.errors[:trn]).to include "Enter a 7 digit teacher reference number (TRN)"
    end
  end

  context "with empty trn provided" do
    let(:trn) { nil }
    let(:date_of_birth) { "1991-01-22" }

    it "returns mentor object with error on trn" do
      mentor = described_class.call(trn:, date_of_birth: Date.parse(date_of_birth))
      expect(mentor.class).to eq(mentor_class)
      expect(mentor.errors[:trn]).to include "Enter a teacher reference number (TRN)"
    end
  end

  context "when trn is not provided as an argument" do
    let(:date_of_birth) { "1991-01-22" }

    it "returns an error with missing keyword: trn" do
      expect { described_class.call(date_of_birth: Date.parse(date_of_birth)) }.to raise_error(ArgumentError, "missing keyword: :trn")
    end
  end

  context "when mentor with trn already exists" do
    let(:existing_mentor) { create(:mentor).becomes(mentor_class) }
    let(:trn) { existing_mentor.trn }
    let(:date_of_birth) { "1991-01-22" }

    before "fetches teacher record from teaching record service" do
      allow(TeachingRecord::GetTeacher).to receive(:call).with(trn:, date_of_birth:).once.and_return(teacher_object)
    end

    it "returns existing mentor" do
      mentor = described_class.call(trn:, date_of_birth: Date.parse(date_of_birth))
      expect(mentor).to eq existing_mentor
    end
  end

  context "when mentor does not exist and valid trn is provided" do
    let(:trn) { "1234567" }
    let(:date_of_birth) { "1991-01-22" }

    before "fetches teacher record from teaching record service" do
      allow(TeachingRecord::GetTeacher).to receive(:call).with(trn:, date_of_birth:).once.and_return(teacher_object)
    end

    it "returns initialized placements mentor record without errors" do
      mentor = described_class.call(trn:, date_of_birth: Date.parse(date_of_birth))
      expect(mentor.class).to eq(mentor_class)
      expect(mentor.trn).to eq trn
      expect(mentor.first_name).to eq teacher_object["firstName"]
      expect(mentor.last_name).to eq teacher_object["lastName"]
      expect(mentor.persisted?).to be false
      expect(mentor.errors.none?).to be true
    end
  end

  context "with valid trn and first_name or last_name args given" do
    let(:trn) { "0987654" }
    let(:first_name) { "Elizabeth" }
    let(:last_name) { "Milner-Lee" }
    let(:date_of_birth) { "1991-01-22" }

    before "fetches teacher record from teaching record service" do
      allow(TeachingRecord::GetTeacher).to receive(:call).with(trn:, date_of_birth:).once.and_return(teacher_object)
    end

    it "returns initialized placements mentor record with first and last name" do
      mentor = described_class.call(trn:, first_name:, last_name:, date_of_birth: Date.parse(date_of_birth))
      expect(mentor.class).to eq(mentor_class)
      expect(mentor.trn).to eq trn
      expect(mentor.first_name).to eq first_name
      expect(mentor.last_name).to eq last_name
      expect(mentor.persisted?).to be false
      expect(mentor.errors.none?).to be true
    end
  end

  def teacher_object
    { "trn" => "1234554",
      "firstName" => "Elizabeth",
      "middleName" => "Elaine",
      "lastName" => "Milner-Lee",
      "dateOfBirth" => "1991-01-22" }
  end
end
