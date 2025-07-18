require "rails_helper"

RSpec.describe Placements::SchoolUserMailer, type: :mailer do
  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.user_membership_created_notification(user, organisation) }

    let(:user) { create(:placements_user) }
    let(:organisation) { create(:placements_school) }

    it "sends invitation email" do
      expect(invite_email.to).to contain_exactly(user.email)
      expect(invite_email.subject).to eq("ACTION NEEDED: Sign-in to the Manage school placements service")
      expect(invite_email.body).to have_content <<~EMAIL
        Dear #{user.first_name},

        You now have access to the Manage school placements service for #{organisation.name}.

        Please sign-in this week to record your school's preferences for offering placements for trainee teachers.

        If you are not the right person to do this, please:

        - access the service using DfE sign-in and add an appropriate colleague in the Users section (you can do this because you are a DfE sign-in approver for your school)
        - forward this email to the appropriate colleague after adding them as a user.

        It is important to do this so teacher training providers know whether to contact your school, and to ensure your school does not miss out on getting trainee teachers.

        ## Sign in to record preferences

        [Use DfE sign-in to access the Manage school placements service](http://placements.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email)

        If your colleague does not have DfE sign-in, they can [create an account](https://services.signin.education.gov.uk/).

        After creating a DfE sign-in account, they will need to return to this email to access the service.

        ## Give feedback or report a problem

        This is a pilot service for schools and teacher training providers in Leeds and Essex.

        If you need help or have feedback for us, contact [Manage.SchoolPlacements@education.gov.uk](mailto:Manage.SchoolPlacements@education.gov.uk).

        Thank you.

        Manage school placements service

        Department for Education
      EMAIL
    end

    context "when HostingEnvironment.env is 'production'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "does not prepend the hosting environment to the subject" do
        expect(invite_email.subject).to eq("ACTION NEEDED: Sign-in to the Manage school placements service")
      end
    end

    context "when HostingEnvironment.env is 'staging'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "prepends the hosting environment to the subject" do
        expect(invite_email.subject).to eq("[STAGING] ACTION NEEDED: Sign-in to the Manage school placements service")
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
      expect(partnership_created_notification_email.subject).to eq("A provider has added you")
      expect(partnership_created_notification_email.body).to have_content <<~EMAIL
        #{user.first_name},

        #{source_organisation.name} has added #{partner_organisation.name} as one of the schools they would like to work with.

        ## What happens next?
        You can now assign them to your placements.

        Contact the provider on [#{source_organisation.email_addresses.first}](mailto:#{source_organisation.email_addresses.first}) if you have any questions.

        ## Your account
        [Sign in to Manage school placements](http://placements.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email)

        Manage school placements service
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

    context "when the provider does not have placements with the school" do
      it "sends a notification email to the user of the school" do
        expect(partnership_destroyed_notification_email.to).to contain_exactly(user.email)
        expect(partnership_destroyed_notification_email.subject).to eq(
          "A provider has removed you",
        )
        expect(partnership_destroyed_notification_email.body).to have_content <<~EMAIL
          #{user.first_name},

          #{source_organisation.name} has deleted #{partner_organisation.name} from the list of schools they work with.

          ## What happens next?
          You will no longer be able to assign placements to this provider unless they add you again or you add them to your list of providers.

          If you think this is a mistake, contact them on [#{source_organisation.email_addresses.first}](mailto:#{source_organisation.email_addresses.first}).

          ## Your account
          [Sign in to Manage school placements](http://placements.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email)

          Manage school placements service
        EMAIL
      end
    end

    context "when the provider has placements with the school" do
      let(:placement) { create(:placement, school: partner_organisation, provider: source_organisation) }

      before { placement }

      it "sends a notification email to the user of the school" do
        expect(partnership_destroyed_notification_email.to).to contain_exactly(user.email)
        expect(partnership_destroyed_notification_email.subject).to eq("A provider has removed you")
        expect(partnership_destroyed_notification_email.body).to have_content <<~EMAIL
          #{user.first_name},

          #{source_organisation.name} has deleted #{partner_organisation.name} from the list of schools they work with.

          ## What happens next?
          They will remain assigned to current placements unless you remove them. These placements are:

          - [#{placement.decorate.title}](http://placements.localhost/schools/#{partner_organisation.id}/placements/#{placement.id}?utm_campaign=school&utm_medium=notification&utm_source=email)

          We recommend you speak to the provider to avoid confusion about placing trainees at your school. Contact them on [#{source_organisation.email_addresses.first}](mailto:#{source_organisation.email_addresses.first}).

          ## Your account
          [Sign in to Manage school placements](http://placements.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email)

          Manage school placements service
        EMAIL
      end
    end
  end

  describe "#placement_provider_removed_notification" do
    subject(:placement_provider_removed_notification) do
      described_class.placement_provider_removed_notification(
        school_user, school, provider, placement
      )
    end

    let(:school) { create(:placements_school, name: "School 1") }
    let(:maths) { create(:subject, name: "Mathematics") }
    let(:placement) { create(:placement, subject: maths, school:) }
    let(:provider) { create(:provider, name: "Provider 1") }
    let(:school_user) { create(:placements_user, schools: [school]) }
    let(:provider_email) { provider.primary_email_address }

    it "sends a provider removed notification email to the user of the school" do
      expect(placement_provider_removed_notification.to).to contain_exactly(school_user.email)
      expect(placement_provider_removed_notification.subject).to eq(
        "You have removed a provider from a placement",
      )
      expect(placement_provider_removed_notification.body).to have_content <<~EMAIL
        #{school_user.first_name},

        You removed #{provider.name} from a placement.

        [#{placement.decorate.title}](http://placements.localhost/schools/#{school.id}/placements/#{placement.id}?utm_campaign=school&utm_medium=notification&utm_source=email)

        ## What happens next?
        You must make sure the provider is aware that they should no longer place a trainee with you. Contact them on [#{provider_email}](mailto:#{provider_email}).

        ## Your account
        [Sign in to the Manage school placements service](http://placements.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email)

        Manage school placements service
      EMAIL
    end
  end

  describe "#placement_information_added_notification" do
    subject(:placement_information_added_notification) do
      described_class.placement_information_added_notification(user, school, placements, academic_year)
    end

    let(:english_subject) { build(:subject, name: "English") }
    let(:placements) { [create(:placement, school: school, subject: english_subject)] }
    let(:hosting_interest) { build(:hosting_interest, academic_year:, appetite: appetite) }
    let(:school) { build(:placements_school, name: "School 1", hosting_interests: [hosting_interest]) }
    let(:user) { create(:placements_user, first_name: "Anne", schools: [school]) }
    let(:academic_year) { create(:placements_academic_year, :next) }

    context "when appetite is actively looking" do
      let(:appetite) { "actively_looking" }

      it "sends a notification email to the user of the school" do
        expect(placement_information_added_notification.to).to contain_exactly(user.email)
        expect(placement_information_added_notification.subject).to eq("You have added placement information to Manage school placements")
        expect(placement_information_added_notification.body).to have_content <<~EMAIL
          Anne,

          You added placements on the Manage school placements service.

          - [English](http://placements.localhost/schools/#{school.id}/placements/#{placements.first.id}?utm_campaign=school&utm_medium=notification&utm_source=email)

          ## What happens next?

          Providers will be able to email [placement_coordinator@example.school](mailto:placement_coordinator@example.school) about your placement offers.

          You do not need to take any further action until providers contact you. After discussions with one or more providers you can then assign providers to your placements.

          ## Your account
          [Sign in to Manage school placements](http://placements.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email)

          Manage school placements service
        EMAIL
      end
    end

    context "when appetite is interested" do
      let(:appetite) { "interested" }

      it "sends a notification email to the user of the school" do
        expect(placement_information_added_notification.to).to contain_exactly(user.email)
        expect(placement_information_added_notification.subject).to eq("You have added placement information to Manage school placements")
        expect(placement_information_added_notification.body).to have_content <<~EMAIL
          Anne,

          You added placements on the Manage school placements service. Providers can see that your school may offer placements.

          - [English](http://placements.localhost/schools/#{school.id}/placements/#{placements.first.id}?utm_campaign=school&utm_medium=notification&utm_source=email)

          ## What happens next?

          Providers will be able to email [placement_coordinator@example.school](mailto:placement_coordinator@example.school) about your placements your school may be able to offer.

          You do not need to take any further action until providers contact you.

          Once you are sure which placements your school can offer you can add individual placements with more detail. You can then assign providers to your placements.

          ## Your account
          [Sign in to Manage school placements](http://placements.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email)

          Manage school placements service
        EMAIL
      end
    end
  end

  describe "#future_of_service_notification" do
    subject(:future_of_service_notification) { described_class.future_of_service_notification(user) }

    let(:user) { create(:placements_user, first_name: "Sam") }

    it "sends invitation email" do
      expect(future_of_service_notification.to).to contain_exactly(user.email)
      expect(future_of_service_notification.subject).to eq("Future of the Manage School Placements Service")
      expect(future_of_service_notification.body.raw_source.gsub("\r\n", "\n")).to have_content <<~EMAIL
        Dear Sam,

        We are writing to inform you of upcoming changes to the Manage School Placements service and to thank you for participating in the pilot of this digital service.

        ## Service Changes from September 2025
        The Manage School Placements service will no longer be available in its current form after September 2025.

        Over the past year we have tested the service, gathered extensive feedback through research with schools and providers and iteratively improved the service throughout. Our aim was to identify ways to support schools to participate in ITT and help providers manage and find school placements.

        Whilst we have gained positive insights through the pilot and identified several features that would bring value to schools and providers, we have decided not to pursue a nationwide roll out of the service.

        For this service to work effectively, we needed to be confident that the vast majority of schools and providers would use it. The pilot has shown that without mandating use of the service – something we did not want to do – it would be extremely difficult to encourage widespread engagement and usage. Existing systems to manage placements, workload concerns, and worries about increasing competition in the placement market were all reasons for a lack of confidence in the service. We took this feedback seriously which is why we have taken the decision not to roll out the service wider.

        However, several aspects of the service did test well, particularly the creation of a process for schools to express an interest in offering placements. We will be exploring ways to enable this process to continue which we will keep you updated on.

        ## What You Need to Do
        To prepare for the closure of the service, we ask that you extract any data you may need from the service by Friday 26th September. If you require assistance with this, please don't hesitate to contact us.

        ## Thank You
        We would like to extend our sincere thanks for your participation in the pilot of this digital service. The insights we've gained have played a crucial role in shaping a more effective solution for both schools and providers.

        If you have any questions or concerns, please feel free to reach out to us.

        Kind regards,

        The Manage school placements team.

        ## Your account
        [Sign in to Manage school placements](http://placements.localhost/sign-in?utm_campaign=email&utm_medium=notification&utm_source=email)

        Manage school placements service
      EMAIL
    end
  end
end
