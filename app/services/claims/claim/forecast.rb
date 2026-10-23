class Claims::Claim::Forecast < ApplicationService
  Group = Struct.new(:name, :rows, :total, keyword_init: true)
  Row = Struct.new(:type_of_establishment, :total, keyword_init: true)
  Result = Struct.new(:groups, :total, keyword_init: true)

  ZERO = Money.new(0, "GBP")

  def initialize(claim_window:)
    @claim_window = claim_window
  end

  def call
    claims = Claims::Claim.not_draft_status.where(claim_window:).includes(:school).to_a

    groups = claims.group_by { |claim| claim.school.group }.reject { |name, _| name.nil? }.sort_by(&:first).map do |name, group_claims|
      rows = group_claims.group_by { |claim| claim.school.type_of_establishment }.reject { |type, _| type.nil? }.sort_by(&:first).map do |type, type_claims|
        Row.new(type_of_establishment: type, total: total_amount(type_claims))
      end

      Group.new(name:, rows:, total: rows.sum(ZERO, &:total))
    end

    Result.new(groups:, total: groups.sum(ZERO, &:total))
  end

  private

  attr_reader :claim_window

  def total_amount(claims)
    claims.sum(ZERO, &:amount)
  end
end
