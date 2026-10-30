class Claims::Claim::Forecast < ApplicationService
  Group = Struct.new(:name, :rows, :total, keyword_init: true)
  Row = Struct.new(:type_of_establishment, :total, keyword_init: true)
  Result = Struct.new(:groups, :total, keyword_init: true)

  ZERO = Money.new(0, "GBP")

  def initialize(claim_window:, status: nil, clawback: false)
    @claim_window = claim_window
    @status = status
    @clawback = clawback
  end

  def call
    groups = grouped_totals.group_by { |(name, _type), _total| name }.reject { |name, _| name.nil? }.sort_by(&:first).map do |name, totals|
      rows = totals.filter_map do |(_name, type), total_pence|
        next if type.nil?

        Row.new(type_of_establishment: type, total: Money.new(total_pence, "GBP"))
      end
      Group.new(name:, rows: rows.sort_by(&:type_of_establishment), total: rows.sum(ZERO, &:total))
    end

    Result.new(groups:, total: groups.sum(ZERO, &:total))
  end

  private

  attr_reader :claim_window, :status, :clawback

  def grouped_totals
    claims = Claims::Claim.not_draft_status.where(claim_window:)
    claims = claims.where(status:) if status
    claims.joins(school: :region)
          .left_joins(:mentor_trainings)
          .group("schools.group", "schools.type_of_establishment")
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
