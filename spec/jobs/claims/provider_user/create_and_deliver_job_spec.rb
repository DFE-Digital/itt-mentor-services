require "rails_helper"

RSpec.describe Claims::ProviderUser::CreateAndDeliverJob, type: :job do
  describe "#perform" do
    let(:provider) { create(:claims_provider) }
    let(:user_details) do
      {
        first_name: "Joe",
        last_name: "Bloggs",
        email: "joe_bloggs@example.com",
      }
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(provider_id: provider.id, user_details:)
      }.to have_enqueued_job(described_class).on_queue("default")
    end

    context "when the user details do not match an existing user" do
      it "creates a provider user, a membership to the provider and dispatches an email to the user" do
        expect {
          described_class.perform_now(provider_id: provider.id, user_details:)
        }.to change(Claims::ProviderUser, :count).by(1)
          .and change(UserMembership, :count).by(1)
          .and enqueue_mail(Claims::ProviderUserMailer, :user_membership_created_notification)

        user = Claims::ProviderUser.find_by!(email: "joe_bloggs@example.com")
        expect(user.first_name).to eq("Joe")
        expect(user.last_name).to eq("Bloggs")

        expect(user.providers).to contain_exactly(provider)
      end
    end

    context "when the user details match an existing user" do
      let(:existing_user) do
        create(
          :claims_provider_user,
          first_name: "Joe",
          last_name: "Bloggs",
          email: "joe_bloggs@example.com",
        )
      end

      before { existing_user }

      context "when the user is not already associated with the provider" do
        it "does not create a user" do
          expect {
            described_class.perform_now(provider_id: provider.id, user_details:)
          }.not_to change(Claims::ProviderUser, :count)
        end

        it "creates a membership to the provider and dispatches an email to the user" do
          expect {
            described_class.perform_now(provider_id: provider.id, user_details:)
          }.to change(UserMembership, :count).by(1)
            .and enqueue_mail(Claims::ProviderUserMailer, :user_membership_created_notification)

          expect(existing_user.providers).to contain_exactly(provider)
        end
      end

      context "when the user is already associated with the provider" do
        before { create(:user_membership, user: existing_user, organisation: provider) }

        it "does not create a user" do
          expect {
            described_class.perform_now(provider_id: provider.id, user_details:)
          }.not_to change(Claims::ProviderUser, :count)
        end

        it "does not create a membership between the user and provider" do
          expect {
            described_class.perform_now(provider_id: provider.id, user_details:)
          }.not_to change(UserMembership, :count)
        end

        it "does not dispatch an email to the user" do
          expect {
            described_class.perform_now(provider_id: provider.id, user_details:)
          }.not_to enqueue_mail(Claims::ProviderUserMailer, :user_membership_created_notification)
        end
      end
    end
  end
end
