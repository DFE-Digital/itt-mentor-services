class Claims::Providers::ClaimsQuery < ApplicationQuery
  STATUS_ORDER = Arel.sql(<<~SQL.squish).freeze
    CASE status
      WHEN 'sampling_in_progress'           THEN 1
      WHEN 'sampling_provider_not_approved' THEN 2
      WHEN 'paid'                           THEN 3
      ELSE 4
    END
  SQL

  def initialize(claims:, params: {})
    super(params:)
    @claims = claims
  end

  def call
    scope = school_condition(claims)
    order_condition(scope)
  end

  private

  attr_reader :claims

  def school_condition(scope)
    school_ids = params[:school_ids]
    return scope if school_ids.blank?

    scope.where(school_id: school_ids)
  end

  def order_condition(scope)
    scope.reorder(STATUS_ORDER)
  end
end
