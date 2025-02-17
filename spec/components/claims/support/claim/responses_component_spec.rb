require "rails_helper"

RSpec.describe Claims::Support::Claim::ResponsesComponent, type: :component do
  before { render_inline(described_class.new(claim:)) }

  describe "render" do
    before { render_inline(described_class.new(claim:)) }

    context "when the claim status is payment_information_requested" do
      let(:claim) { build(:claim, :payment_information_requested, unpaid_reason:) }

      context "when an unpaid reason is present" do
        let(:unpaid_reason) { "A reason unpaid" }

        it "renders the unpaid reason" do
          expect(page).to have_element(:div, class: "claim-responses")

          expect(page).to have_element(:h3, text: "Reason claim was not paid", class: "govuk-heading-s")
          expect(page).to have_element(:p, text: "A reason unpaid", class: "govuk-body")
        end
      end

      context "when an unpaid reason is blank" do
        let(:unpaid_reason) { nil }

        it "does not render the unpaid reason" do
          expect(page).not_to have_element(:div, class: "claim-responses")

          expect(page).not_to have_element(:h3, text: "Reason claim was not paid", class: "govuk-heading-s")
        end
      end
    end

    context "when the claim status is payment_information_sent" do
      let(:claim) { build(:claim, :payment_information_sent, unpaid_reason:) }

      context "when an unpaid reason is present" do
        let(:unpaid_reason) { "A reason unpaid" }

        it "renders the response" do
          expect(page).to have_element(:div, class: "claim-responses")

          expect(page).to have_element(:h3, text: "Reason claim was not paid", class: "govuk-heading-s")
          expect(page).to have_element(:p, text: "A reason unpaid", class: "govuk-body")
        end
      end

      context "when an unpaid reason is blank" do
        let(:unpaid_reason) { nil }

        it "does not render the response" do
          expect(page).not_to have_element(:div, class: "claim-responses")

          expect(page).not_to have_element(:h3, text: "Reason claim was not paid", class: "govuk-heading-s")
        end
      end
    end

    context "when the claim status is sampling_in_progress" do
      let(:claim) { build(:claim, :audit_requested, sampling_reason:) }

      context "when a sampling reason is present" do
        let(:sampling_reason) { "Suspicious claim" }

        it "renders the sampling reason" do
          expect(page).to have_element(:div, class: "claim-responses")

          expect(page).to have_element(:h3, text: "Reason claim is being audited", class: "govuk-heading-s")
          expect(page).to have_element(:p, text: "Suspicious claim", class: "govuk-body")
        end
      end

      context "when a sampling reason is blank" do
        let(:sampling_reason) { nil }

        it "does not render the sampling reason" do
          expect(page).not_to have_element(:div, class: "claim-responses")

          expect(page).not_to have_element(:h3, text: "Reason claim is being audited", class: "govuk-heading-s")
        end
      end
    end

    context "when the claim status is sampling_provider_not_approved" do
      let(:mentor_1) { build(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
      let(:mentor_training_1) do
        build(:mentor_training,
              :not_assured,
              mentor: mentor_1,
              reason_not_assured: "Incorrect number of hours")
      end
      let(:mentor_2) { build(:claims_mentor, first_name: "Sarah", last_name: "Doe") }
      let(:mentor_training_2) do
        build(:mentor_training,
              :not_assured,
              mentor: mentor_2,
              reason_not_assured: "Invalid mentor")
      end
      let(:claim) do
        create(:claim,
               :audit_requested,
               status: :sampling_provider_not_approved,
               mentor_trainings: [mentor_training_1, mentor_training_2])
      end

      it "renders the provider's response" do
        expect(page).to have_element(:div, class: "claim-responses")

        expect(page).to have_element(:h3, text: "Provider response", class: "govuk-heading-s")
        expect(page).to have_element(
          :ul,
          text: "Joe Bloggs: Incorrect number of hoursSarah Doe: Invalid mentor",
          class: "govuk-list",
        )
      end
    end

    context "when the claim status is sampling_not_approved" do
      let(:mentor_1) { build(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
      let(:mentor_training_1) do
        build(:mentor_training,
              :rejected,
              mentor: mentor_1,
              reason_not_assured: "Incorrect number of hours",
              reason_rejected: "Claimed too many hours")
      end
      let(:mentor_2) { build(:claims_mentor, first_name: "Sarah", last_name: "Doe") }
      let(:mentor_training_2) do
        build(:mentor_training,
              :rejected,
              mentor: mentor_2,
              reason_not_assured: "Invalid mentor",
              reason_rejected: "No longer working at this school")
      end
      let(:claim) do
        create(:claim,
               :audit_requested,
               status: :sampling_not_approved,
               mentor_trainings: [mentor_training_1, mentor_training_2])
      end

      it "renders the provider's and school's response" do
        expect(page).to have_element(:details, class: "claim-responses")
        expect(page).to have_element(:span,
                                     text: "Why the claim was rejected",
                                     class: "govuk-details__summary-text")
        expect(page).to have_element(:p,
                                     text: "Provider comments - #{claim.provider_name}",
                                     class: "govuk-heading-s",
                                     visible: :all)
        expect(page).to have_element(
          :ul,
          text: "Joe Bloggs: Incorrect number of hoursSarah Doe: Invalid mentor",
          class: "govuk-list",
          visible: :all,
        )
        expect(page).to have_element(:p,
                                     text: "School comments - #{claim.school_name}",
                                     class: "govuk-heading-s",
                                     visible: :all)
        expect(page).to have_element(
          :ul,
          text: "Joe Bloggs: Claimed too many hoursSarah Doe: No longer working at this school",
          class: "govuk-list",
          visible: :all,
        )
      end
    end

    context "when the claim status is clawback_in_progress" do
      let(:mentor_1) { build(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
      let(:mentor_training_1) do
        build(:mentor_training,
              :rejected,
              mentor: mentor_1,
              reason_not_assured: "Incorrect number of hours",
              reason_rejected: "Claimed too many hours")
      end
      let(:mentor_2) { build(:claims_mentor, first_name: "Sarah", last_name: "Doe") }
      let(:mentor_training_2) do
        build(:mentor_training,
              :rejected,
              mentor: mentor_2,
              reason_not_assured: "Invalid mentor",
              reason_rejected: "No longer working at this school")
      end
      let(:claim) do
        create(:claim,
               :audit_requested,
               status: :clawback_in_progress,
               mentor_trainings: [mentor_training_1, mentor_training_2])
      end

      it "renders the provider's and school's response" do
        expect(page).to have_element(:details, class: "claim-responses")
        expect(page).to have_element(:span,
                                     text: "Why the claim was rejected",
                                     class: "govuk-details__summary-text")
        expect(page).to have_element(:p,
                                     text: "Provider comments - #{claim.provider_name}",
                                     class: "govuk-heading-s",
                                     visible: :all)
        expect(page).to have_element(
          :ul,
          text: "Joe Bloggs: Incorrect number of hoursSarah Doe: Invalid mentor",
          class: "govuk-list",
          visible: :all,
        )
        expect(page).to have_element(:p,
                                     text: "School comments - #{claim.school_name}",
                                     class: "govuk-heading-s",
                                     visible: :all)
        expect(page).to have_element(
          :ul,
          text: "Joe Bloggs: Claimed too many hoursSarah Doe: No longer working at this school",
          class: "govuk-list",
          visible: :all,
        )
      end
    end

    context "when the claim status is clawback_requested" do
      let(:mentor_1) { build(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
      let(:mentor_training_1) do
        build(:mentor_training,
              :rejected,
              mentor: mentor_1,
              reason_not_assured: "Incorrect number of hours",
              reason_rejected: "Claimed too many hours")
      end
      let(:mentor_2) { build(:claims_mentor, first_name: "Sarah", last_name: "Doe") }
      let(:mentor_training_2) do
        build(:mentor_training,
              :rejected,
              mentor: mentor_2,
              reason_not_assured: "Invalid mentor",
              reason_rejected: "No longer working at this school")
      end
      let(:claim) do
        create(:claim,
               :audit_requested,
               status: :clawback_requested,
               mentor_trainings: [mentor_training_1, mentor_training_2])
      end

      it "renders the provider's and school's response" do
        expect(page).to have_element(:details, class: "claim-responses")
        expect(page).to have_element(:span,
                                     text: "Why the claim was rejected",
                                     class: "govuk-details__summary-text")
        expect(page).to have_element(:p,
                                     text: "Provider comments - #{claim.provider_name}",
                                     class: "govuk-heading-s",
                                     visible: :all)
        expect(page).to have_element(
          :ul,
          text: "Joe Bloggs: Incorrect number of hoursSarah Doe: Invalid mentor",
          class: "govuk-list",
          visible: :all,
        )
        expect(page).to have_element(:p,
                                     text: "School comments - #{claim.school_name}",
                                     class: "govuk-heading-s",
                                     visible: :all)
        expect(page).to have_element(
          :ul,
          text: "Joe Bloggs: Claimed too many hoursSarah Doe: No longer working at this school",
          class: "govuk-list",
          visible: :all,
        )
      end
    end

    context "when the claim status is clawback_complete" do
      let(:mentor_1) { build(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
      let(:mentor_training_1) do
        build(:mentor_training,
              :rejected,
              mentor: mentor_1,
              reason_not_assured: "Incorrect number of hours",
              reason_rejected: "Claimed too many hours")
      end
      let(:mentor_2) { build(:claims_mentor, first_name: "Sarah", last_name: "Doe") }
      let(:mentor_training_2) do
        build(:mentor_training,
              :rejected,
              mentor: mentor_2,
              reason_not_assured: "Invalid mentor",
              reason_rejected: "No longer working at this school")
      end
      let(:claim) do
        create(:claim,
               :audit_requested,
               status: :clawback_complete,
               mentor_trainings: [mentor_training_1, mentor_training_2])
      end

      it "renders the provider's and school's response" do
        expect(page).to have_element(:details, class: "claim-responses")
        expect(page).to have_element(:span,
                                     text: "Why the claim was rejected",
                                     class: "govuk-details__summary-text")
        expect(page).to have_element(:p,
                                     text: "Provider comments - #{claim.provider_name}",
                                     class: "govuk-heading-s",
                                     visible: :all)
        expect(page).to have_element(
          :ul,
          text: "Joe Bloggs: Incorrect number of hoursSarah Doe: Invalid mentor",
          class: "govuk-list",
          visible: :all,
        )
        expect(page).to have_element(:p,
                                     text: "School comments - #{claim.school_name}",
                                     class: "govuk-heading-s",
                                     visible: :all)
        expect(page).to have_element(
          :ul,
          text: "Joe Bloggs: Claimed too many hoursSarah Doe: No longer working at this school",
          class: "govuk-list",
          visible: :all,
        )
      end
    end
  end

  describe "#provider_response_exists?" do
    subject(:provider_response_exists) { described_class.new(claim:).provider_response_exists? }

    let(:claim) do
      create(:claim,
             :audit_requested,
             status: :sampling_provider_not_approved,
             mentor_trainings: [mentor_training])
    end

    context "when the mentor trainings associated with a claim have a reason not assured" do
      let(:mentor_training) do
        build(:mentor_training, :not_assured)
      end

      it "returns true" do
        expect(provider_response_exists).to be(true)
      end
    end

    context "when the mentor trainings associated with a claim do not have a reason not assured" do
      let(:mentor_training) do
        build(:mentor_training)
      end

      it "returns false" do
        expect(provider_response_exists).to be(false)
      end
    end
  end

  describe "#school_response_exists?" do
    subject(:school_response_exists) { described_class.new(claim:).school_response_exists? }

    let(:claim) do
      create(:claim,
             :audit_requested,
             status: :sampling_not_approved,
             mentor_trainings: [mentor_training])
    end

    context "when the mentor trainings associated with a claim have a reason rejected" do
      let(:mentor_training) do
        build(:mentor_training, :rejected)
      end

      it "returns true" do
        expect(school_response_exists).to be(true)
      end
    end

    context "when the mentor trainings associated with a claim do not have a reason rejected" do
      let(:mentor_training) do
        build(:mentor_training)
      end

      it "returns false" do
        expect(school_response_exists).to be(false)
      end
    end
  end

  describe "#provider_response" do
    subject(:provider_response) { described_class.new(claim:).provider_response }

    let(:claim) do
      create(:claim,
             :audit_requested,
             status: :sampling_provider_not_approved,
             mentor_trainings:)
    end
    let(:mentor_1) { build(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
    let(:mentor_2) { build(:claims_mentor, first_name: "Sarah", last_name: "Doe") }

    context "when the mentor trainings associated with a claim have a reason not assured" do
      let(:mentor_training_1) do
        build(:mentor_training,
              :not_assured,
              mentor: mentor_1,
              reason_not_assured: "Incorrect number of hours")
      end
      let(:mentor_training_2) do
        build(:mentor_training,
              :not_assured,
              mentor: mentor_2,
              reason_not_assured: "Invalid mentor")
      end
      let(:mentor_trainings) { [mentor_training_1, mentor_training_2] }

      it "returns true" do
        expect(provider_response).to eq(
          "<ul class=\"govuk-list\"><li>Joe Bloggs: Incorrect number of hours</li><li>Sarah Doe: Invalid mentor</li></ul>",
        )
      end
    end

    context "when the mentor trainings associated with a claim do not have a reason not assured" do
      let(:mentor_trainings) do
        build_list(:mentor_training, 2)
      end

      it "returns false" do
        expect(provider_response).to eq("")
      end
    end
  end

  describe "#school_response" do
    subject(:school_response) { described_class.new(claim:).school_response }

    let(:claim) do
      create(:claim,
             :audit_requested,
             status: :sampling_not_approved,
             mentor_trainings:)
    end
    let(:mentor_1) { build(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
    let(:mentor_2) { build(:claims_mentor, first_name: "Sarah", last_name: "Doe") }

    context "when the mentor trainings associated with a claim have a reason rejected" do
      let(:mentor_training_1) do
        build(:mentor_training,
              :rejected,
              mentor: mentor_1,
              not_assured: true,
              reason_rejected: "Incorrect number of hours")
      end
      let(:mentor_training_2) do
        build(:mentor_training,
              :rejected,
              mentor: mentor_2,
              not_assured: true,
              reason_rejected: "Invalid mentor")
      end
      let(:mentor_trainings) { [mentor_training_1, mentor_training_2] }

      it "returns true" do
        expect(school_response).to eq(
          "<ul class=\"govuk-list\"><li>Joe Bloggs: Incorrect number of hours</li><li>Sarah Doe: Invalid mentor</li></ul>",
        )
      end
    end

    context "when the mentor trainings associated with a claim do not have a reason rejected" do
      let(:mentor_trainings) do
        build_list(:mentor_training, 2)
      end

      it "returns false" do
        expect(school_response).to eq("")
      end
    end
  end
end
