require "rails_helper"

RSpec.describe Claims::UserResearch::ProviderClaimsDemoReset do
  subject(:reset_service) { described_class.new }

  describe "private helpers" do
    describe "#provider" do
      before do
        Claims::Provider.find_by(code: described_class::DEMO_PROVIDER_CODE)&.destroy!
      end

      it "creates the demo provider with expected defaults" do
        provider = nil

        expect {
          provider = reset_service.send(:provider)
        }.to change(Claims::Provider.where(code: described_class::DEMO_PROVIDER_CODE), :count).by(1)

        expect(provider).to have_attributes(
          code: described_class::DEMO_PROVIDER_CODE,
          name: described_class::DEMO_PROVIDER_NAME,
          accredited: true,
        )
      end
    end

    describe "#school_for_claim" do
      let(:fallback_school) { create(:claims_school, name: "Fallback School") }

      it "returns the fallback school when no school name is supplied" do
        claim_definition = { school_name: nil }

        selected_school = reset_service.send(:school_for_claim, claim_definition, fallback_school)

        expect(selected_school).to eq(fallback_school)
      end

      it "finds a matching school by name, ignoring case" do
        matching_school = create(:claims_school, name: "St Gregory's Catholic Primary School")
        claim_definition = { school_name: "st gregory's catholic primary school" }

        selected_school = reset_service.send(:school_for_claim, claim_definition, fallback_school)

        expect(selected_school).to eq(matching_school)
      end
    end

    describe "#create_demo_claim" do
      let(:school) { create(:claims_school) }
      let(:mentor_1) { create(:claims_mentor, schools: [school]) }
      let(:mentor_2) { create(:claims_mentor, schools: [school]) }

      it "creates a non-sampling claim without a sampling reason" do
        # Ensure mentors are created before the test runs
        _ = [mentor_1, mentor_2]

        expect {
          reset_service.send(
            :create_demo_claim,
            school: school,
            reference: "99990001",
            status: :paid,
            training_type: :initial,
            academic_year: :current,
            claim_window_index: 0,
          )
        }.to change(Claims::Claim, :count).by(1)
         .and change(Claims::MentorTraining, :count).by(school.mentors.count)

        claim = Claims::Claim.order(:created_at).last
        expect(claim.status).to eq("paid")
        expect(claim.sampling_reason).to be_nil
      end
    end
  end
end
