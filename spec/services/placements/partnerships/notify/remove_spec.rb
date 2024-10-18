require "rails_helper"

RSpec.describe Placements::Partnerships::Notify::Remove do
  let(:provider) { create(:placements_provider) }
  let(:school) { create(:placements_school) }

  it_behaves_like "a service object" do
    let(:params) do
      {
        source_organisation: create(:provider),
        partner_organisation: create(:school),
      }
    end
  end

  describe "#call" do
    context "when the partner organisation is onboarded on the placements service" do
      let(:school) { create(:school, :placements) }
      let(:provider) { create(:provider, :placements) }

      context "when the partner organisation is a provider" do
        subject(:partnership_notify_removal) do
          described_class.call(
            source_organisation: school,
            partner_organisation: provider,
          )
        end

        let!(:user_1) { create(:placements_user, providers: [provider]) }
        let!(:user_2) { create(:placements_user, providers: [provider]) }

        it "sends a notification email to every user belonging to the provider" do
          expect { partnership_notify_removal }.to have_enqueued_mail(
            Placements::UserMailer,
            :partnership_destroyed_notification,
          ).with(
            user_1, school, provider
          ).and have_enqueued_mail(
            Placements::UserMailer,
            :partnership_destroyed_notification,
          ).with(
            user_2, school, provider
          )
        end
      end

      context "when the partner organisation is a school" do
        subject(:partnership_notify_removal) do
          described_class.call(
            source_organisation: provider,
            partner_organisation: school,
          )
        end

        let!(:user_1) { create(:placements_user, schools: [school]) }
        let!(:user_2) { create(:placements_user, schools: [school]) }
        let!(:user_3) { create(:claims_user, schools: [school]) }

        it "sends a notification email to every user belonging to the school" do
          expect { partnership_notify_removal }.to have_enqueued_mail(
            Placements::UserMailer,
            :partnership_destroyed_notification,
          ).with(
            user_1, provider, school
          ).and have_enqueued_mail(
            Placements::UserMailer,
            :partnership_destroyed_notification,
          ).with(
            user_2, provider, school
          )
        end

        it "does not send a notification email to users not belonging to the school" do
          expect { partnership_notify_removal }.not_to have_enqueued_mail(
            Placements::UserMailer,
            :partnership_destroyed_notification,
          ).with(
            user_3, provider, school
          )
        end
      end
    end

    context "when the partner organisation is not onboarded on the placements service" do
      let(:school) { create(:school) }
      let(:provider) { create(:provider) }

      context "when the partner organisation is a provider" do
        subject(:partnership_notify_removal) do
          described_class.call(
            source_organisation: school,
            partner_organisation: provider,
          )
        end

        let(:user_1) { create(:placements_user, providers: [provider]) }
        let(:user_2) { create(:placements_user, providers: [provider]) }

        before do
          user_1
          user_2
        end

        it "does not send a notification email" do
          expect { partnership_notify_removal }.not_to have_enqueued_mail(
            Placements::UserMailer,
            :partnership_destroyed_notification,
          )
        end
      end

      context "when the partner organisation is a school" do
        subject(:partnership_notify_removal) do
          described_class.call(
            source_organisation: provider,
            partner_organisation: school,
          )
        end

        let(:user_1) { create(:placements_user, schools: [school]) }
        let(:user_2) { create(:placements_user, schools: [school]) }

        before do
          user_1
          user_2
        end

        it "does not send a notification email" do
          expect { partnership_notify_removal }.not_to have_enqueued_mail(
            Placements::UserMailer,
            :partnership_destroyed_notification,
          )
        end
      end
    end
  end
end
