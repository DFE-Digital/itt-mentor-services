require "rails_helper"

RSpec.describe Claims::Sampling::SendEvidenceDeadlineNotificationsJob, type: :job do
  subject(:notify_creators) { described_class.new.perform }

  let(:creator) { create(:claims_user) }
  let!(:claim) do
    create(:claim,
           status: :sampling_provider_not_approved,
           created_by: creator,
           amendment_notification_sent_at: Time.zone.local(2026, 10, 5, 9))
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2026, 11, 5, 9)) { example.run }
  end

  it "enqueues the email only for the claim creator and records the notification" do
    create(:claims_user, schools: [claim.school])

    expect { notify_creators }
      .to have_enqueued_mail(Claims::UserMailer, :claim_amendment_evidence_deadline_passed_notification)
      .with(creator, claim).exactly(:once)
      .and change { claim.reload.amendment_deadline_notification_sent_at }.from(nil).to(Time.current)
  end

  it "does not enqueue the email again on subsequent days" do
    notify_creators

    Timecop.travel(1.day.from_now) do
      expect { described_class.new.perform }.not_to have_enqueued_mail(Claims::UserMailer)
    end
  end

  it "does not enqueue the email when another worker notifies the claim before it is locked" do
    notified_at = 1.minute.ago

    allow(Claims::Claim).to receive(:transaction).and_wrap_original do |transaction, **options, &block|
      # The selected record is stale until with_lock reloads it from the database.
      claim.update_column(:amendment_deadline_notification_sent_at, notified_at)
      transaction.call(**options, &block)
    end

    expect { notify_creators }.not_to have_enqueued_mail(Claims::UserMailer)
    expect(claim.reload.amendment_deadline_notification_sent_at).to eq(notified_at)
  end

  it "does not enqueue the email again after the claim leaves and returns to the amended status" do
    notify_creators
    Claims::AuditContext.set(system_operation: "test setup") do
      claim.update!(status: :sampling_in_progress)
      claim.update!(status: :sampling_provider_not_approved)
    end

    expect { described_class.new.perform }.not_to have_enqueued_mail(Claims::UserMailer)
  end

  it "does not enqueue the email before the deadline" do
    Timecop.travel(Time.zone.local(2026, 11, 3, 9)) do
      expect { notify_creators }.not_to have_enqueued_mail(Claims::UserMailer)
    end
    expect(claim.reload.amendment_deadline_notification_sent_at).to be_nil
  end

  it "does not enqueue the email during the deadline day" do
    Timecop.travel(Time.zone.local(2026, 11, 4, 23, 59, 59)) do
      expect { notify_creators }.not_to have_enqueued_mail(Claims::UserMailer)
    end
    expect(claim.reload.amendment_deadline_notification_sent_at).to be_nil
  end

  it "waits until after a weekend-extended deadline" do
    claim.update!(amendment_notification_sent_at: Time.zone.local(2026, 10, 1, 9))

    Timecop.travel(Time.zone.local(2026, 11, 2, 9)) do
      expect { notify_creators }.not_to have_enqueued_mail(Claims::UserMailer)
    end
    Timecop.travel(Time.zone.local(2026, 11, 3, 9)) do
      expect { described_class.new.perform }.to have_enqueued_mail(Claims::UserMailer)
    end
  end

  it "does not notify claims without an initial amendment notification" do
    claim.update!(amendment_notification_sent_at: nil)

    expect { notify_creators }.not_to have_enqueued_mail(Claims::UserMailer)
    expect(claim.reload.amendment_deadline_notification_sent_at).to be_nil
  end

  it "does not notify claims in other statuses" do
    Claims::AuditContext.set(system_operation: "test setup") { claim.update!(status: :clawback_requested) }

    expect { notify_creators }.not_to have_enqueued_mail(Claims::UserMailer)
    expect(claim.reload.amendment_deadline_notification_sent_at).to be_nil
  end

  it "leaves the claim eligible for retry when enqueueing raises an error" do
    allow(Claims::UserMailer).to receive(:claim_amendment_evidence_deadline_passed_notification)
      .and_raise(ActiveJob::EnqueueError, "Queue unavailable")

    expect { notify_creators }.to raise_error(ActiveJob::EnqueueError, "Queue unavailable")
    expect(claim.reload.amendment_deadline_notification_sent_at).to be_nil
  end

  it "surfaces an unsuccessful enqueue without recording the notification" do
    delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: false)
    allow(Claims::UserMailer).to receive(:claim_amendment_evidence_deadline_passed_notification).and_return(delivery)

    expect { notify_creators }.to raise_error(ActiveJob::EnqueueError, /Could not enqueue evidence deadline notification/)
    expect(claim.reload.amendment_deadline_notification_sent_at).to be_nil
  end
end
