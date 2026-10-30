class Claims::Claim::Forecast < ApplicationService
  Group = Struct.new(:name, :rows, :total, keyword_init: true)
  Row = Struct.new(:type_of_establishment, :total, keyword_init: true)
  Result = Struct.new(:groups, :total, keyword_init: true)
  ClawbackReports = Struct.new(:pending, :completed, keyword_init: true)

  ZERO = Money.new(0, "GBP")
  PENDING_CLAWBACK_STATUSES = %w[clawback_requires_approval clawback_requested clawback_in_progress].freeze

  def self.clawbacks(claim_window:)
    new(claim_window:, status: PENDING_CLAWBACK_STATUSES + %w[clawback_complete], clawback: true).clawback_reports
  end

  def initialize(claim_window:, status: nil, clawback: false)
    @claim_window = claim_window
    @status = status
    @clawback = clawback
  end

  def call
    build_result(grouped_totals)
  end

  def clawback_reports
    pending = Hash.new(0)
    completed = Hash.new(0)
    grouped_totals(by_status: true).each do |(name, type, claim_status), total|
      totals = claim_status == "clawback_complete" ? completed : pending
      totals[[name, type]] += total
    end

    ClawbackReports.new(pending: build_result(pending), completed: build_result(completed))
  end

  private

  attr_reader :claim_window, :status, :clawback

  def build_result(grouped_totals)
    groups = grouped_totals.group_by { |(name, _type), _total| name }.reject { |name, _| name.nil? }.sort_by(&:first).map do |name, totals|
      rows = totals.filter_map do |(_name, type), total_pence|
        next if type.nil?

        Row.new(type_of_establishment: type, total: Money.new(total_pence, "GBP"))
      end
      Group.new(name:, rows: rows.sort_by(&:type_of_establishment), total: rows.sum(ZERO, &:total))
    end

    Result.new(groups:, total: groups.sum(ZERO, &:total))
  end

  def grouped_totals(by_status: false)
    claims = Claims::Claim.not_draft_status.where(claim_window:)
    claims = claims.where(status:) if status
    columns = ["schools.group", "schools.type_of_establishment"]
    columns << "claims.status" if by_status
    claims.joins(school: :region)
          .left_joins(:mentor_trainings)
          .group(*columns)
          .sum(amount_in_pence)
  end

  def amount_in_pence
    hours = if clawback
              "CASE WHEN mentor_trainings.not_assured THEN COALESCE(mentor_trainings.hours_clawed_back, 0) ELSE 0 END"
            else
              "COALESCE(mentor_trainings.hours_completed, 0)"
            end

    Arel.sql("(#{hours})::bigint * regions.claims_funding_available_per_hour_pence")
  end
end
