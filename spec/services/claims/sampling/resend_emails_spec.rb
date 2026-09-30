require "rails_helper"

describe Claims::Sampling::ResendEmails do
  subject(:resend_emails) { described_class.call(provider_sampling:, provider_users:) }

  let(:provider_sampling) { create(:provider_sampling, provider:) }
  let(:provider) { create(:claims_provider) }
  let(:provider_user) { create(:claims_provider_user, email: "example@provider.com", providers: [provider]) }
  let(:provider_user_2) { create(:claims_provider_user, email: "example2@provider.com", providers: [provider]) }
  let(:provider_user_3) { create(:claims_provider_user, email: "example3@provider.com", providers: [provider]) }
  let(:download_access_token) { create(:download_access_token, activity_record: provider_sampling, email_address: "example@provider.com") }
  let(:download_access_token_2) { create(:download_access_token, activity_record: provider_sampling, email_address: "example2@provider.com") }
  let(:download_access_token_3) { create(:download_access_token, activity_record: provider_sampling, email_address: "example3@provider.com") }

  describe "#call" do
    context "when given the provider's users" do
      before do
        download_access_token
        download_access_token_2
        download_access_token_3
      end

      let(:provider_users) { [provider_user, provider_user_2, provider_user_3] }

      it "enqueues the delivery of an email to each provider user" do
        expect { resend_emails }.to enqueue_mail(Claims::ProviderMailer, :resend_sampling_checks_required).exactly(3)
        .and enqueue_mail(Claims::ProviderMailer, :resend_sampling_checks_required).with(provider_sampling, provider_user)
        .and enqueue_mail(Claims::ProviderMailer, :resend_sampling_checks_required).with(provider_sampling, provider_user_2)
        .and enqueue_mail(Claims::ProviderMailer, :resend_sampling_checks_required).with(provider_sampling, provider_user_3)
      end

      it "destroys all download access tokens for the given provider users" do
        expect { resend_emails }.to change { provider_sampling.download_access_tokens.count }.from(3).to(0)
      end
    end

    context "when given users who do not belong to the provider" do
      let(:provider_users) { [create(:claims_provider_user), provider_user_2, provider_user_3] }

      it "raises an invalid provider users error" do
        expect { resend_emails }.to raise_error(Claims::Sampling::ResendEmails::InvalidProviderUsersError)
        .and not_enqueue_mail(Claims::ProviderMailer, :resend_sampling_checks_required)
      end
    end
  end
end
