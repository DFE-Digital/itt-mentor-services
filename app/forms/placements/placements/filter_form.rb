class Placements::Placements::FilterForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :school_ids, default: []
  attribute :subject_ids, default: []
  attribute :school_types, default: []
  attribute :partner_school_ids, default: []
  attribute :available, default: nil

  def initialize(params = {})
    params.each_value(&:compact_blank!)

    super(params)
  end

  def filters_selected?
    attributes.values.compact.flatten.any?
  end

  def clear_filters_path(provider)
    placements_provider_placements_path(provider)
  end

  def index_path_without_filter(provider:, filter:, value: nil)
    without_filter = compacted_attributes.merge(
      filter => compacted_attributes[filter].reject { |filter_value| filter_value == value },
    )

    placements_provider_placements_path(
      provider_id: provider,
      params: { filters: without_filter },
    )
  end

  def query_params
    {
      school_ids:,
      subject_ids:,
      school_types:,
      partner_school_ids:,
      available:,
    }
  end

  def schools
    @schools ||= School.where(id: school_ids).order_by_name
  end

  def subjects
    @subjects ||= Subject.where(id: subject_ids).order_by_name
  end

  def partner_schools
    @partner_schools ||= School.where(id: partner_school_ids).order_by_name
  end

  private

  def compacted_attributes
    @compacted_attributes ||= attributes.compact_blank
  end
end
