require "rails_helper"

describe Claims::Claim::ChangeProvider do
  subject(:call) { described_class.call(claim:, provider: new_provider) }

  let(:old_provider) { create(:claims_provider, name: "Old Provider") }
  let(:new_provider) { create(:claims_provider, name: "New Provider") }
  let!(:new_provider_user) { create(:claims_provider_user, providers: [new_provider]) }
  let(:claim) { create(:claim, :submitted, status:, provider: old_provider) }
  let!(:mentor_training) do
    create(
      :mentor_training,
      claim:,
      provider: old_provider,
      hours_completed: 20,
      not_assured: true,
      reason_not_assured: "Mentor did not attend",
      hours_clawed_back: 5,
    )
  end

  context "when the claim is submitted" do
    let(:status) { :submitted }

    it "changes the provider on the claim" do
      expect { call }.to change { claim.reload.provider }.from(old_provider).to(new_provider)
    end

    it "changes the provider on the mentor trainings" do
      expect { call }.to change { mentor_training.reload.provider }.from(old_provider).to(new_provider)
    end

    it "does not change the status of the claim" do
      expect { call }.not_to(change { claim.reload.status })
    end

    it "does not create a provider sampling" do
      expect { call }.not_to change(Claims::ProviderSampling, :count)
    end

    it "does not email the new provider" do
      expect { call }.not_to have_enqueued_mail(Claims::ProviderMailer, :sampling_checks_required)
    end

    context "when the mentor has already claimed some hours with the new provider" do
      before { claim_hours_with_new_provider(15) }

      it "reduces the hours to the maximum they can claim with the new provider" do
        expect { call }.to change { mentor_training.reload.hours_completed }.from(20).to(5)
      end
    end

    context "when the mentor has no hours left with the new provider" do
      before { claim_hours_with_new_provider(20) }

      it "removes the mentor training from the claim" do
        expect { call }.to change { claim.mentor_trainings.exists?(mentor_training.id) }.from(true).to(false)
      end
    end

    context "when the mentor has trained with the new provider in a previous year" do
      before do
        previous_claim_window = create(:claim_window, :historic)
        previous_claim = create(:claim, :submitted, provider: new_provider, claim_window: previous_claim_window)
        create(:mentor_training, claim: previous_claim, mentor: mentor_training.mentor, provider: new_provider, hours_completed: 1)
      end

      it "changes the training to refresher training, capped at the refresher hours" do
        call

        mentor_training.reload
        expect(mentor_training.training_type).to eq("refresher")
        expect(mentor_training.hours_completed).to eq(Claims::TrainingHours.new(academic_year: claim.academic_year).refresher)
      end
    end
  end

  context "when the claim requires an audit" do
    let(:status) { :sampling_in_progress }
    let!(:old_provider_sampling) do
      create(:provider_sampling, provider: old_provider, claims: [claim], created_at: 20.days.ago)
    end

    it "changes the provider on the claim and mentor trainings" do
      call

      expect(claim.reload.provider).to eq(new_provider)
      expect(mentor_training.reload.provider).to eq(new_provider)
    end

    it "keeps the claim in audit requested" do
      expect { call }.not_to change { claim.reload.status }.from("sampling_in_progress")
    end

    it "creates a provider sampling for the new provider in the same sampling, resetting the 30 day window, without a CSV file" do
      Timecop.freeze(Time.current.change(usec: 0)) do
        expect { call }.to change(Claims::ProviderSampling.where(provider: new_provider), :count).by(1)

        provider_sampling = Claims::ProviderSampling.find_by!(provider: new_provider)
        expect(provider_sampling.claims).to contain_exactly(claim)
        expect(provider_sampling.sampling).to eq(old_provider_sampling.sampling)
        expect(provider_sampling.created_at).to eq(Time.current)
        expect(provider_sampling.csv_file).not_to be_attached
      end
    end

    it "emails the users of the new provider" do
      expect { call }.to have_enqueued_mail(Claims::ProviderMailer, :sampling_checks_required)
        .with(an_instance_of(Claims::ProviderSampling), new_provider_user).once
    end
  end

  context "when the claim has been amended by the provider" do
    let(:status) { :sampling_provider_not_approved }

    before do
      create(:provider_sampling, provider: old_provider, claims: [claim], created_at: 40.days.ago)
      claim.update!(amendment_notification_sent_at: 10.days.ago)
    end

    it "sets the claim back to audit requested" do
      expect { call }.to change { claim.reload.status }
        .from("sampling_provider_not_approved")
        .to("sampling_in_progress")
    end

    it "clears the amendment notification date" do
      expect { call }.to change { claim.reload.amendment_notification_sent_at }.to(nil)
    end

    it "clears the old provider's responses from the mentor trainings" do
      call

      mentor_training.reload
      expect(mentor_training.not_assured).to be(false)
      expect(mentor_training.reason_not_assured).to be_nil
      expect(mentor_training.hours_clawed_back).to be_nil
    end

    it "creates a provider sampling for the new provider" do
      expect { call }.to change(Claims::ProviderSampling.where(provider: new_provider), :count).by(1)
    end

    it "emails the users of the new provider" do
      expect { call }.to have_enqueued_mail(Claims::ProviderMailer, :sampling_checks_required)
        .with(an_instance_of(Claims::ProviderSampling), new_provider_user).once
    end
  end

  private

  def claim_hours_with_new_provider(hours_completed)
    other_claim = create(:claim, :submitted, provider: new_provider)
    create(:mentor_training, claim: other_claim, mentor: mentor_training.mentor, provider: new_provider, hours_completed:)
  end
end
