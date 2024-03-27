module Filterable
  extend ActiveSupport::Concern

  def filter_by(filters = {})
    scope = @scope

    filters.each do |key, value|
      scope = send("by_#{key}", value, scope) if value.present?
    end

    scope
  end
end
