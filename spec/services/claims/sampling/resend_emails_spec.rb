require "rails_helper"

describe Claims::Sampling::ResendEmails do
  subject(:resend_emails) { described_class.call(provider_sampling:, email_addresses:) }

  let(:provider_sampling) { create(:provider_sampling, provider:) }
  let(:download_access_token) { create(:download_access_token, activity_record: provider_sampling, email_address: "example@provider.com") }
  let(:download_access_token_2) { create(:download_access_token, activity_record: provider_sampling, email_address: "example2@provider.com") }
  let(:download_access_token_3) { create(:download_access_token, activity_record: provider_sampling, email_address: "example3@provider.com") }

  let(:provider) { create(:claims_provider, email_addresses: %w[example@provider.com example2@provider.com example3@provider.com]) }

  describe "#call" do
    context "when given valid provider email addresses" do
      before do
        download_access_token
        download_access_token_2
        download_access_token_3
      end

      let(:email_addresses) { %w[example@provider.com example2@provider.com example3@provider.com] }

      it "enqueues the delivery of an email to each provider email address" do
        expect { resend_emails }.to enqueue_mail(Claims::ProviderMailer, :resend_sampling_checks_required).exactly(3)
        .and enqueue_mail(Claims::ProviderMailer, :resend_sampling_checks_required).with(provider_sampling, "example@provider.com")
        .and enqueue_mail(Claims::ProviderMailer, :resend_sampling_checks_required).with(provider_sampling, "example2@provider.com")
        .and enqueue_mail(Claims::ProviderMailer, :resend_sampling_checks_required).with(provider_sampling, "example3@provider.com")
      end

      it "destroys all download access tokens for the given email addresses" do
        expect { resend_emails }.to change { provider_sampling.download_access_tokens.count }.from(3).to(0)
      end
    end

    context "when given invalid provider email addresses" do
      let(:email_addresses) { ["invalid@provider.com", "example2@provider.com", "example3@provider.com"] }

      it "raises an invalid email addresses error" do
        expect { resend_emails }.to raise_error(Claims::Sampling::ResendEmails::InvalidEmailAddressesError)
        .and not_enqueue_mail(Claims::ProviderMailer, :resend_sampling_checks_required)
      end
    end
  end
end
