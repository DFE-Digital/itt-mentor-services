require "rails_helper"

RSpec.describe Claims::User::CreateAndDeliverJob, type: :job do
  describe "#perform" do
    let(:school) { create(:claims_school) }
    let(:user_details) do
      {
        first_name: "Joe",
        last_name: "Bloggs",
        email: "joe_bloggs@example.com",
      }
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(school_id: school.id, user_details:)
      }.to have_enqueued_job(described_class).on_queue("default")
    end

    context "when the user details do not match an existing user" do
      it "creates a user, a membership to the school and dispatches an email to the user" do
        expect {
          described_class.perform_now(school_id: school.id, user_details:)
        }.to change(Claims::User, :count).by(1)
          .and change(UserMembership, :count).by(1)
          .and enqueue_mail(Claims::UserMailer, :user_membership_created_notification)

        user = Claims::User.find_by!(email: "joe_bloggs@example.com")
        expect(user.first_name).to eq("Joe")
        expect(user.last_name).to eq("Bloggs")

        expect(user.schools).to contain_exactly(school)
      end
    end

    context "when the user details match an existing user" do
      let(:existing_user) do
        create(
          :claims_user,
          first_name: "Joe",
          last_name: "Bloggs",
          email: "joe_bloggs@example.com",
        )
      end

      before { existing_user }

      context "when the user is not already associated with the school" do
        it "does not create a user" do
          expect {
            described_class.perform_now(school_id: school.id, user_details:)
          }.not_to change(Claims::User, :count)
        end

        it "creates a membership to the school and dispatches an email to the user" do
          expect {
            described_class.perform_now(school_id: school.id, user_details:)
          }.to change(UserMembership, :count).by(1)
            .and enqueue_mail(Claims::UserMailer, :user_membership_created_notification)

          expect(existing_user.schools).to contain_exactly(school)
        end
      end

      context "when the user is already associated with the school" do
        before { create(:user_membership, user: existing_user, organisation: school) }

        it "does not create a user" do
          expect {
            described_class.perform_now(school_id: school.id, user_details:)
          }.not_to change(Claims::User, :count)
        end

        it "does not create a membership between the user and school" do
          expect {
            described_class.perform_now(school_id: school.id, user_details:)
          }.not_to change(UserMembership, :count)
        end

        it "does not dispatch an email to the user" do
          expect {
            described_class.perform_now(school_id: school.id, user_details:)
          }.not_to enqueue_mail(Claims::UserMailer, :user_membership_created_notification)
        end
      end
    end
  end
end
