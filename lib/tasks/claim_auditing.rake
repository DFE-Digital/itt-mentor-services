namespace :claims do
  namespace :claim_auditing do
    desc "Backfill claim status changes from preserved Audited records"
    task backfill: :environment do
      boolean = ActiveModel::Type::Boolean.new
      report = Claims::ClaimStatusChange::Backfill.call(
        claim_id: ENV["CLAIM_ID"].presence,
        dry_run: boolean.cast(ENV.fetch("DRY_RUN", "true")),
        limit: ENV["LIMIT"].presence&.to_i || 500,
        after_audit_id: ENV["AFTER_AUDIT_ID"].presence&.to_i,
        high_water_mark: ENV["HIGH_WATER_MARK"].presence&.to_i,
      )

      puts JSON.pretty_generate(report)
    end

    desc "Reconcile claim status changes against preserved evidence"
    task reconcile: :environment do
      baseline_file = ENV.fetch("BASELINE_FILE") do
        raise ArgumentError, "Set BASELINE_FILE to the retained backfill dry-run JSON report"
      end
      raise ArgumentError, "Baseline file does not exist: #{baseline_file}" unless File.file?(baseline_file)

      report = Claims::ClaimStatusChange::Reconcile.call(
        claim_id: ENV["CLAIM_ID"].presence,
        baseline: JSON.parse(File.read(baseline_file)),
      )

      puts JSON.pretty_generate(report)
    end
  end
end
