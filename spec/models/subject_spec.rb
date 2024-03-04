# == Schema Information
#
# Table name: subjects
#
#  id           :uuid             not null, primary key
#  code         :string
#  name         :string           not null
#  subject_area :enum
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "rails_helper"

RSpec.describe Subject, type: :model do
  it { is_expected.to have_many(:placement_subject_joins).dependent(:restrict_with_exception) }
  it { is_expected.to have_many(:placements).through(:placement_subject_joins) }

  it { is_expected.to validate_presence_of(:subject_area) }
  it { is_expected.to validate_presence_of(:name) }

  describe "scopes" do
    describe "#order_by_name" do
      it "returns the subjects ordered by name" do
        subject1 = create(:subject, name: "English")
        subject2 = create(:subject, name: "Art")
        subject3 = create(:subject, name: "Science")

        expect(described_class.order_by_name).to eq(
          [subject2, subject1, subject3],
        )
      end
    end
  end
end
