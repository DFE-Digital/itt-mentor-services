require "rails_helper"

describe Claims::Clawback::ResendEmail do
  subject(:resend_email) { described_class.call(clawback:) }

  let(:claims) { create_list(:claim, 1, :submitted) }
  let(:clawback) { create(:clawback, claims: claims) }

  describe "#call" do
    it "enqueues the delivery of an email" do
      expect { resend_email }.to enqueue_mail(Claims::ESFAMailer, :resend_claims_require_clawback).once
    end
  end
end
