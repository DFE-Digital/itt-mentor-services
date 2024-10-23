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
        "A school has added you",
      )

      expect(partnership_created_notification_email.body).to have_content <<~EMAIL
        #{user.first_name},

        #{source_organisation.name} has added #{partner_organisation.name} as one of the providers they would like to work with.

        ##What happens next?
        They can now assign you to their placements. Once assigned to a specific placement, you should plan to place a trainee.

        Contact the school on [#{source_organisation.school_contact_email_address}](mailto:#{source_organisation.school_contact_email_address}) if you have any questions.

        ##Your account
        [Sign in to Manage school placements](http://placements.localhost/sign-in)

        Manage school placements service
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

    context "when the provider does not have placements associated with the school" do
      it "sends a notification email to the user of the provider" do
        expect(partnership_destroyed_notification_email.to).to contain_exactly(user.email)
        expect(partnership_destroyed_notification_email.subject).to eq(
          "A school has removed you",
        )
        expect(partnership_destroyed_notification_email.body).to have_content <<~EMAIL
          #{user.first_name},

          #{source_organisation.name} has deleted #{partner_organisation.name} from the list of providers they work with.

          ##What happens next?
          You will no longer be assigned placements by this school unless they add you again or you add them to your list of schools.

          If you think this is a mistake, contact them on [#{source_organisation.school_contact_email_address}](mailto:#{source_organisation.school_contact_email_address}).

          ##Your account
          [Sign in to Manage school placements](http://placements.localhost/sign-in)

          Manage school placements service
        EMAIL
      end
    end

    context "when the provider has one placement associated with the school" do
      let(:placement) { create(:placement, school: source_organisation, provider: partner_organisation) }

      before { placement }

      it "sends a notification email to the user of the provider" do
        expect(partnership_destroyed_notification_email.to).to contain_exactly(user.email)
        expect(partnership_destroyed_notification_email.subject).to eq(
          "A school has removed you",
        )
        expect(partnership_destroyed_notification_email.body).to have_content <<~EMAIL
          #{user.first_name},

          #{source_organisation.name} has deleted #{partner_organisation.name} from the list of providers they work with.

          ##What happens next?
          You will remain assigned to current placements for this academic year unless the school removes you. This placement is:

          - [#{placement.decorate.title}](http://placements.localhost/providers/#{partner_organisation.id}/placements/#{placement.id})

          We recommend you speak to the school to check whether they expect you to fill this placement. Contact them on [#{source_organisation.school_contact_email_address}](mailto:#{source_organisation.school_contact_email_address}).

          ##Your account
          [Sign in to Manage school placements](http://placements.localhost/sign-in)

          Manage school placements service
        EMAIL
      end
    end

    context "when the provider has multiple placements associated with the school" do
      let(:placement_one) { create(:placement, school: source_organisation, provider: partner_organisation) }
      let(:placement_two) { create(:placement, school: source_organisation, provider: partner_organisation) }

      before do
        placement_one
        placement_two
      end

      it "sends a notification email to the user of the provider" do
        expect(partnership_destroyed_notification_email.to).to contain_exactly(user.email)
        expect(partnership_destroyed_notification_email.subject).to eq("A school has removed you")
        expect(partnership_destroyed_notification_email.body).to have_content <<~EMAIL
          #{user.first_name},

          #{source_organisation.name} has deleted #{partner_organisation.name} from the list of providers they work with.

          ##What happens next?
          You will remain assigned to current placements for this academic year unless the school removes you. These placements are:

          - [#{placement_one.decorate.title}](http://placements.localhost/providers/#{partner_organisation.id}/placements/#{placement_one.id})
          - [#{placement_two.decorate.title}](http://placements.localhost/providers/#{partner_organisation.id}/placements/#{placement_two.id})

          We recommend you speak to the school to check whether they expect you to fill these placements. Contact them on [#{source_organisation.school_contact_email_address}](mailto:#{source_organisation.school_contact_email_address}).

          ##Your account
          [Sign in to Manage school placements](http://placements.localhost/sign-in)

          Manage school placements service
        EMAIL
      end
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
        "A school wants you to place a trainee with them",
      )
      expect(placement_provider_assigned_notification.body).to have_content <<~EMAIL
        #{provider_user.first_name},

        #{school.name} has assigned #{provider.name} to the following placement:

        - [#{placement.decorate.title}](http://placements.localhost/providers/#{provider.id}/placements/#{placement.id})

        ##What happens next?
        You should now arrange for one of your trainees to fulfil this placement.

        Contact the school at [#{school.school_contact_email_address}](mailto:#{school.school_contact_email_address}).

        ##Your account
        [Sign in to Manage school placements](http://placements.localhost/sign-in)

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
        "A school has removed you from a placement",
      )
      expect(placement_provider_removed_notification.body).to have_content <<~EMAIL
        #{provider_user.first_name},

        #{school.name} has removed #{provider.name} from the following placement:

        - [#{placement.decorate.title}](http://placements.localhost/providers/#{provider.id}/placements/#{placement.id})

        You can no longer allocate a trainee onto this placement.

        ##What happens next?
        If you think this is a mistake, contact the school on [#{school.school_contact_email_address}](mailto:#{school.school_contact_email_address}).

        ##Your account
        [Sign in to Manage school placements](http://placements.localhost/sign-in)

        Manage school placements service
      EMAIL
    end
  end
end
