require "rails_helper"

RSpec.describe Placements::Partnerships::Notify::Create do
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
        subject(:partnership_notify_creation) do
          described_class.call(
            source_organisation: school,
            partner_organisation: provider,
          )
        end

        let!(:user_1) { create(:placements_user, providers: [provider]) }
        let!(:user_2) { create(:placements_user, providers: [provider]) }
        let!(:user_3) { create(:claims_user, schools: [school]) }

        it "sends a notification email to every user belonging to the provider" do
          expect { partnership_notify_creation }.to have_enqueued_mail(
            Placements::ProviderUserMailer,
            :partnership_created_notification,
          ).with(
            user_1, school, provider
          ).and have_enqueued_mail(
            Placements::ProviderUserMailer,
            :partnership_created_notification,
          ).with(
            user_2, school, provider
          )
        end

        it "does not send a notification email to users not belonging to the placements service" do
          expect { partnership_notify_creation }.not_to have_enqueued_mail(
            Placements::ProviderUserMailer,
            :partnership_created_notification,
          ).with(
            user_3, provider, school
          )
        end
      end

      context "when the partner organisation is a school" do
        subject(:partnership_notify_creation) do
          described_class.call(
            source_organisation: provider,
            partner_organisation: school,
          )
        end

        let!(:user_1) { create(:placements_user, schools: [school]) }
        let!(:user_2) { create(:placements_user, schools: [school]) }
        let!(:user_3) { create(:claims_user, schools: [school]) }

        it "sends a notification email to every placements user belonging to the school" do
          expect { partnership_notify_creation }.to have_enqueued_mail(
            Placements::SchoolUserMailer,
            :partnership_created_notification,
          ).with(
            user_1, provider, school
          ).and have_enqueued_mail(
            Placements::SchoolUserMailer,
            :partnership_created_notification,
          ).with(
            user_2, provider, school
          )
        end

        it "does not send a notification email to users not belonging to the placements service" do
          %i[SchoolUserMailer ProviderUserMailer].each do |mailer_class|
            expect { partnership_notify_creation }.not_to have_enqueued_mail(
              "Placements::#{mailer_class}".constantize,
              :partnership_created_notification,
            ).with(
              user_3, provider, school
            )
          end
        end
      end
    end

    context "when the partner organisation is not onboarded on the placements service" do
      let(:school) { create(:school) }
      let(:provider) { create(:provider) }

      context "when the partner organisation is a provider" do
        subject(:partnership_notify_creation) do
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
          expect { partnership_notify_creation }.not_to have_enqueued_mail(
            Placements::SchoolUserMailer,
            :partnership_created_notification,
          )
        end
      end

      context "when the partner organisation is a school" do
        subject(:partnership_notify_creation) do
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
          expect { partnership_notify_creation }.not_to have_enqueued_mail(
            Placements::ProviderUserMailer,
            :partnership_created_notification,
          )
        end
      end
    end
  end
end
