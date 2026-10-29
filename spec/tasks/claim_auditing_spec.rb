require "rails_helper"
require "rake"

describe "claims:claim_auditing" do
  Rails.application.load_tasks if Rake::Task.tasks.empty?

  let(:backfill_task) { Rake::Task["claims:claim_auditing:backfill"] }
  let(:reconcile_task) { Rake::Task["claims:claim_auditing:reconcile"] }

  before do
    backfill_task.reenable
    reconcile_task.reenable
    allow($stdout).to receive(:puts)
  end

  it "defaults backfill to dry-run and a bounded page" do
    ClimateControl.modify(DRY_RUN: nil, LIMIT: nil, CLAIM_ID: nil, AFTER_AUDIT_ID: nil, HIGH_WATER_MARK: nil) do
      allow(Claims::ClaimStatusChange::Backfill).to receive(:call).and_return({})
      backfill_task.invoke

      expect(Claims::ClaimStatusChange::Backfill).to have_received(:call).with(
        claim_id: nil,
        dry_run: true,
        limit: 500,
        after_audit_id: nil,
        high_water_mark: nil,
      )
    end
  end

  it "passes the selected cursor and high-water mark to backfill" do
    ClimateControl.modify(
      CLAIM_ID: SecureRandom.uuid,
      DRY_RUN: "false",
      LIMIT: "20",
      AFTER_AUDIT_ID: "120",
      HIGH_WATER_MARK: "400",
    ) do
      allow(Claims::ClaimStatusChange::Backfill).to receive(:call).and_return({})
      backfill_task.invoke

      expect(Claims::ClaimStatusChange::Backfill).to have_received(:call).with(
        claim_id: ENV["CLAIM_ID"],
        dry_run: false,
        limit: 20,
        after_audit_id: 120,
        high_water_mark: 400,
      )
    end
  end

  it "loads and passes the retained report to reconciliation" do
    baseline = { "high_water_mark" => 400, "source_snapshot" => {} }
    ClimateControl.modify(CLAIM_ID: nil, BASELINE_FILE: "approved-report.json") do
      allow(File).to receive(:file?).with("approved-report.json").and_return(true)
      allow(File).to receive(:read).with("approved-report.json").and_return(JSON.generate(baseline))
      allow(Claims::ClaimStatusChange::Reconcile).to receive(:call).and_return({})
      reconcile_task.invoke

      expect(Claims::ClaimStatusChange::Reconcile).to have_received(:call).with(claim_id: nil, baseline:)
    end
  end

  it "requires a retained baseline report for reconciliation" do
    ClimateControl.modify(BASELINE_FILE: nil) do
      expect { reconcile_task.invoke }
        .to raise_error(ArgumentError, /BASELINE_FILE/)
    end
  end

  it "rejects a baseline path that does not exist" do
    ClimateControl.modify(BASELINE_FILE: "missing-report.json") do
      allow(File).to receive(:file?).with("missing-report.json").and_return(false)

      expect { reconcile_task.invoke }
        .to raise_error(ArgumentError, /does not exist/)
    end
  end
end
