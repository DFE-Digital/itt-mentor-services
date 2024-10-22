require "rails_helper"

RSpec.describe Placements::SchoolUserMailer, type: :mailer do
  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.user_membership_created_notification(user, organisation) }

    let(:user) { create(:placements_user) }
    let(:organisation) { create(:placements_school) }

    it "sends invitation email" do
      expect(invite_email.to).to contain_exactly(user.email)
      expect(invite_email.subject).to eq("Invitation to join Manage school placements")
      expect(invite_email.body).to have_content <<~EMAIL
        #{user.first_name},

        You have been invited to join the Manage school placements service for #{organisation.name}.

        This service allows you to publish and manage placements at your school. You can assign your preferred providers to fulfil your placements with suitable trainees.

        [Sign in to Manage school placements](http://placements.localhost/sign-in)

        If you do not have DfE Sign-in, create an account. You can then return to this email to access the service.

        If you need help or have feedback for us, contact [Manage.SchoolPlacements@education.gov.uk](mailto:Manage.SchoolPlacements@education.gov.uk).

        Manage school placements service
      EMAIL
    end

    context "when HostingEnvironment.env is 'production'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "does not prepend the hosting environment to the subject" do
        expect(invite_email.subject).to eq("Invitation to join Manage school placements")
      end
    end

    context "when HostingEnvironment.env is 'staging'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "prepends the hosting environment to the subject" do
        expect(invite_email.subject).to eq("[STAGING] Invitation to join Manage school placements")
      end
    end
  end

  describe "#user_membership_destroyed_notification" do
    subject(:removal_email) { described_class.user_membership_destroyed_notification(user, organisation) }

    let(:user) { create(:placements_user) }
    let(:organisation) { create(:placements_school) }

    it "sends expected message to user" do
      expect(removal_email.to).to contain_exactly user.email
      expect(removal_email.subject).to eq "You have been removed from Manage school placements"
      expect(removal_email.body).to have_content <<~EMAIL
        #{user.first_name},

        You no longer have access to the Manage school placements service for #{organisation.name}. This is because someone at this school removed you.

        If you think this is a mistake, speak to [#{organisation.school_contact_email_address}](mailto:#{organisation.school_contact_email_address}).

        Manage school placements service
      EMAIL
    end

    context "when HostingEnvironment.env is 'production'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "does not prepend the hosting environment to the subject" do
        expect(removal_email.subject).to eq("You have been removed from Manage school placements")
      end
    end

    context "when HostingEnvironment.env is 'staging'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "prepends the hosting environment to the subject" do
        expect(removal_email.subject).to eq("[STAGING] You have been removed from Manage school placements")
      end
    end
  end

  describe "#partnership_created_notification" do
    subject(:partnership_created_notification_email) do
      described_class.partnership_created_notification(user, source_organisation, partner_organisation)
    end

    let(:source_organisation) { create(:placements_provider, name: "Provider 1") }
    let(:partner_organisation) { create(:placements_school, name: "School 1") }
    let(:user) { create(:placements_user, schools: [partner_organisation]) }

    it "sends a notification email to the user of the school" do
      expect(partnership_created_notification_email.to).to contain_exactly(user.email)
      expect(partnership_created_notification_email.subject).to eq(
        "A teacher training provider has added your organisation to its list of partner schools",
      )
      expect(partnership_created_notification_email.body).to have_content <<~EMAIL
        Dear #{user.full_name},

        You are receiving this notification because #{source_organisation.name} has added #{partner_organisation.name} to its list of partner schools.

        View or manage your list of partner providers http://placements.localhost/schools/#{partner_organisation.id}/partner_providers
      EMAIL
    end
  end

  describe "#partnership_destroyed_notification" do
    subject(:partnership_destroyed_notification_email) do
      described_class.partnership_destroyed_notification(user, source_organisation, partner_organisation)
    end

    let(:source_organisation) { create(:placements_provider, name: "Provider 1") }
    let(:partner_organisation) { create(:placements_school, name: "School 1") }

    let(:user) { create(:placements_user, schools: [partner_organisation]) }

    it "sends a notification email to the user of the school" do
      expect(partnership_destroyed_notification_email.to).to contain_exactly(user.email)
      expect(partnership_destroyed_notification_email.subject).to eq(
        "A teacher training provider has removed your organisation from its list of partner schools",
      )
      expect(partnership_destroyed_notification_email.body).to have_content <<~EMAIL
        Dear #{user.full_name},

        You are receiving this notification because #{source_organisation.name} has removed #{partner_organisation.name} from its list of partner schools.

        View or manage your list of partner providers http://placements.localhost/schools/#{partner_organisation.id}/partner_providers
      EMAIL
    end
  end
end
