require "rails_helper"

describe Claim::MentorTrainingForm, type: :model do
  let!(:claim) { create(:claim) }
  let!(:mentor_training) { create(:mentor_training, claim:, mentor:, hours_completed: 6) }
  let(:mentor) { create(:mentor, first_name: "Anne") }
  let(:hours_completed) { 20 }

  describe "validations" do
    context "when hours_completed is blank" do
      it "returns invalid" do
        form = described_class.new(claim:, mentor_training:)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:hours_completed]).to include("Select the number of hours")
      end
    end

    context "when custom_hours_completed is blank and user clicked on custom hours radio button" do
      it "returns invalid" do
        form = described_class.new(claim:, mentor_training:, hours_completed: "on")
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:custom_hours_completed]).to include("Enter the number of hours")
      end
    end
  end

  describe "save" do
    it "adds hours completed to the mentor_training " do
      mentor_training_with_custom_hours = create(
        :mentor_training,
        claim:,
        mentor: create(:mentor),
      )

      form = described_class.new(
        claim:,
        mentor_training: mentor_training_with_custom_hours,
        hours_completed: "20",
      )

      expect {
        form.save!
      }.to change { mentor_training_with_custom_hours.hours_completed }.to eq(20)
    end

    context "when custom_hours_completed is available" do
      it "adds hours custom_hours_completed to the mentor_training " do
        mentor_training_with_completed_hours = create(
          :mentor_training,
          hours_completed: 20,
          claim:,
          mentor: create(:mentor),
        )

        form = described_class.new(
          claim:,
          mentor_training: mentor_training_with_completed_hours,
          hours_completed: "on",
          custom_hours_completed: "12",
        )

        expect {
          form.save!
        }.to change { mentor_training_with_completed_hours.hours_completed }.to eq(12)
      end
    end

    describe "#back_path" do
      context "when we are on the first mentor training hours page" do
        it "returns the path to the mentors check list" do
          form = described_class.new(claim:, mentor_training:)

          expect(form.back_path).to eq(
            "/schools/#{claim.school_id}/claims/#{claim.id}/mentors/#{mentor_training.mentor_id}/edit",
          )
        end
      end

      context "when we are on the second mentor training hours page" do
        it "returns the path to the first mentor training" do
          second_mentor_training = create(
            :mentor_training,
            claim:,
            mentor: create(:mentor, first_name: "John"),
          )
          form = described_class.new(claim:, mentor_training: second_mentor_training)

          expect(form.back_path).to eq(
            "/schools/#{claim.school_id}/claims/#{claim.id}/mentor_trainings/#{mentor_training.id}/edit?claim_mentor_training_form%5Bhours_completed%5D=#{mentor_training.hours_completed}",
          )
        end
      end
    end

    describe "#success_path" do
      context "when there are no more mentor trainings without hours completed" do
        it "returns the path to the check page" do
          form = described_class.new(claim:, mentor_training:)

          expect(form.success_path).to eq(
            "/schools/#{claim.school_id}/claims/#{claim.id}/check",
          )
        end
      end

      context "when there are mentor trainings without hours completed" do
        it "returns the path to the next mentor training hours" do
          mentor_training_without_hours = create(
            :mentor_training,
            claim:,
            mentor: create(:mentor),
          )
          form = described_class.new(claim:, mentor_training:)

          expect(form.success_path).to eq(
            "/schools/#{claim.school_id}/claims/#{claim.id}/mentor_trainings/#{mentor_training_without_hours.id}/edit",
          )
        end
      end
    end

    describe "#custom_hours?" do
      context "when user choosed the radio button to input custom hours" do
        it "returns true" do
          form = described_class.new(claim:, mentor_training:, hours_completed: "on")
          expect(form.custom_hours?).to eq(true)
        end
      end

      context "when the mentor training has custom_hours_completed" do
        it "returns true" do
          mentor_training_with_custom_hours = create(
            :mentor_training,
            hours_completed: 12,
            claim:,
            mentor: create(:mentor),
          )

          form = described_class.new(
            claim:,
            mentor_training: mentor_training_with_custom_hours,
            hours_completed: "12",
          )
          expect(form.custom_hours?).to eq(true)
        end
      end

      context "when the mentor training has pre-determened hours_completed" do
        it "returns false" do
          form = described_class.new(claim:, mentor_training:, hours_completed: "20")
          expect(form.custom_hours?).to eq(false)
        end
      end
    end
  end

  describe "#custom_hours?" do
    context "when user inputs pre selected hours" do
      it "returns false" do
        form = described_class.new(claim:, mentor_training:, hours_completed: "20")
        expect(form.custom_hours?).to eq(false)
      end
    end

    context "when user inputs custom hours" do
      it "returns true" do
        form = described_class.new(claim:, mentor_training:, hours_completed: "on")
        expect(form.custom_hours?).to eq(true)
      end
    end

    context "when user edits custom hours" do
      it "returns true" do
        form = described_class.new(claim:, mentor_training:, hours_completed: "12")
        expect(form.custom_hours?).to eq(true)
      end
    end
  end
end
