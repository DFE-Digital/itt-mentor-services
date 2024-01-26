require "rails_helper"

RSpec.describe NotifyMailer, type: :mailer do
  describe "#send_organisation_invite_email" do
    subject { described_class.send_organisation_invite_email(user, organisation, "") }

    context "when the user's service is Claims" do
      let(:user) { create(:claims_user, first_name: "Anne", last_name: "Wilson") }
      let(:organisation) { create(:school, :claims, name: "School 1") }
      let(:service) { "claims" }

      it "invites the user to the organsation" do
        expect(subject.to).to contain_exactly(user.email)
        expect(subject.subject).to eq("You have been invited to School 1")

        expect(subject.body.encoded).to eq(
          "Dear Anne Wilson \r\n\r\n You have been invited to join the claims" \
          " service for School 1.\r\n\r\n Sign in here ",
        )
      end
    end

    context "when the user's service is Placements" do
      let(:user) { create(:placements_user, first_name: "Anne", last_name: "Wilson") }
      let(:service) { "placements" }

      context "when the organisation is a school" do
        let(:organisation) { create(:school, :placements, name: "School 1") }

        it "invites the user to the organsation" do
          expect(subject.to).to contain_exactly(user.email)
          expect(subject.subject).to eq("You have been invited to School 1")
          expect(subject.body.encoded).to eq(
            "Dear Anne Wilson \r\n\r\n You have been invited to join the school placements" \
            " service for School 1.\r\n\r\n Sign in here ",
          )
        end
      end

      context "when the organisation is a Provider" do
        let(:organisation) { create(:placements_provider, name: "School 1") }
        let(:service) { "placements" }

        it "invites the user to the organsation" do
          expect(subject.to).to contain_exactly(user.email)
          expect(subject.subject).to eq("You have been invited to School 1")
          expect(subject.body.encoded).to eq(
            "Dear Anne Wilson \r\n\r\n You have been invited to join the school placements" \
            " service for School 1.\r\n\r\n Sign in here ",
          )
        end
      end
    end
  end
end
