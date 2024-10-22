require "rails_helper"

RSpec.describe Placements::ProviderUserMailer, type: :mailer do
  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.user_membership_created_notification(user, organisation) }

    let(:user) { create(:placements_user) }
    let(:organisation) { create(:placements_provider) }

    it "sends invitation email" do
      expect(invite_email.to).to contain_exactly(user.email)
      expect(invite_email.subject).to eq("Invitation to join Manage school placements")
      expect(invite_email.body).to have_content <<~EMAIL
        #{user.first_name},

        You have been invited to join the Manage school placements service for #{organisation.name}.

        This service allows you to view placements published by schools. Schools can also assign you to placements they want you to place a trainee on.

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
    let(:organisation) { create(:placements_provider) }

    it "sends expected message to user" do
      expect(removal_email.to).to contain_exactly user.email
      expect(removal_email.subject).to eq "You have been removed from Manage school placements"
      expect(removal_email.body).to have_content <<~EMAIL
        #{user.first_name},

        You no longer have access to the Manage school placements service for #{organisation.name}. This is because someone at this organisation removed you.

        If you think this is a mistake, speak to someone at your organisation.

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

    let(:source_organisation) { create(:placements_school, name: "School 1") }
    let(:partner_organisation) { create(:placements_provider, name: "Provider 1") }
    let(:user) { create(:placements_user, providers: [partner_organisation]) }

    it "sends a notification email to the user of the provider" do
      expect(partnership_created_notification_email.to).to contain_exactly(user.email)
      expect(partnership_created_notification_email.subject).to eq(
        "A school has added your organisation to its list of partner providers",
      )

      expect(partnership_created_notification_email.body).to have_content <<~EMAIL
        Dear #{user.full_name},

        You are receiving this notification because #{source_organisation.name} has added #{partner_organisation.name} to its list of partner providers.

        View or manage your list of partner schools http://placements.localhost/providers/#{partner_organisation.id}/partner_schools
      EMAIL
    end
  end

  describe "#partnership_destroyed_notification" do
    subject(:partnership_destroyed_notification_email) do
      described_class.partnership_destroyed_notification(user, source_organisation, partner_organisation)
    end

    let(:source_organisation) { create(:placements_school, name: "School 1") }
    let(:partner_organisation) { create(:placements_provider, name: "Provider 1") }
    let(:user) { create(:placements_user, providers: [partner_organisation]) }

    it "sends a notification email to the user of the provider" do
      expect(partnership_destroyed_notification_email.to).to contain_exactly(user.email)
      expect(partnership_destroyed_notification_email.subject).to eq(
        "A school has removed your organisation from its list of partner providers",
      )
      expect(partnership_destroyed_notification_email.body).to have_content <<~EMAIL
        Dear #{user.full_name},

        You are receiving this notification because #{source_organisation.name} has removed #{partner_organisation.name} from its list of partner providers.

        View or manage your list of partner schools http://placements.localhost/providers/#{partner_organisation.id}/partner_schools
      EMAIL
    end
  end

  describe "#placement_provider_assigned_notification" do
    subject(:placement_provider_assigned_notification) do
      described_class.placement_provider_assigned_notification(
        provider_user, provider, placement
      )
    end

    let(:school) { create(:placements_school, name: "School 1") }
    let(:maths) { create(:subject, name: "Mathematics") }
    let(:placement) { create(:placement, subject: maths, school:) }
    let(:provider) { create(:provider, name: "Provider 1") }
    let(:provider_user) { create(:placements_user, providers: [provider]) }
    let(:school_contact_email) { school.school_contact.email_address }

    it "sends a provider assigned notification email to the user of the provider" do
      expect(placement_provider_assigned_notification.to).to contain_exactly(provider_user.email)
      expect(placement_provider_assigned_notification.subject).to eq(
        "School 1 wants you to place a trainee with them",
      )
      expect(placement_provider_assigned_notification.body).to have_content <<~EMAIL
        Provider 1 has been assigned to the following placement:

        [School 1](http://placements.localhost/providers/#{provider.id}/placements/#{placement.id})
        [Mathematics](http://placements.localhost/providers/#{provider.id}/placements/#{placement.id})

        # What happens next?

        Contact the school to suggest a trainee you think would suit this placement.#{" "}
        Get in touch at [#{school_contact_email}](mailto:#{school_contact_email})

        Manage school placements service
      EMAIL
    end
  end

  describe "#placement_provider_removed_notification" do
    subject(:placement_provider_removed_notification) do
      described_class.placement_provider_removed_notification(
        provider_user, provider, placement
      )
    end

    let(:school) { create(:placements_school, name: "School 1") }
    let(:maths) { create(:subject, name: "Mathematics") }
    let(:placement) { create(:placement, subject: maths, school:) }
    let(:provider) { create(:provider, name: "Provider 1") }
    let(:provider_user) { create(:placements_user, providers: [provider]) }
    let(:school_contact_email) { school.school_contact.email_address }

    it "sends a provider assigned notification email to the user of the provider" do
      expect(placement_provider_removed_notification.to).to contain_exactly(provider_user.email)
      expect(placement_provider_removed_notification.subject).to eq(
        "School 1 has removed you from a placement",
      )
      expect(placement_provider_removed_notification.body).to have_content <<~EMAIL
        Provider 1 is no longer able to allocate a trainee on the following placement:

        [School 1](http://placements.localhost/providers/#{provider.id}/placements/#{placement.id})
        [Mathematics](http://placements.localhost/providers/#{provider.id}/placements/#{placement.id})

        # What happens next?

        No further action is required.#{" "}
        If you think this is a mistake, contact the school at [#{school_contact_email}](mailto:#{school_contact_email})

        Manage school placements service
      EMAIL
    end
  end
end
