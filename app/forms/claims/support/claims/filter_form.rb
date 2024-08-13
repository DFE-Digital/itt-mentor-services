class Claims::Support::Claims::FilterForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :search
  attribute :search_school
  attribute :search_provider
  attribute "submitted_after(1i)"
  attribute "submitted_after(2i)"
  attribute "submitted_after(3i)"
  attribute "submitted_before(1i)"
  attribute "submitted_before(2i)"
  attribute "submitted_before(3i)"
  attribute :school_ids, default: []
  attribute :provider_ids, default: []
  attribute :statuses, default: []

  def initialize(params = {})
    params[:school_ids].compact_blank! if params[:school_ids].present?
    params[:provider_ids].compact_blank! if params[:provider_ids].present?

    super(params)
  end

  def filters_selected?
    school_ids.present? ||
      provider_ids.present? ||
      submitted_after.present? ||
      submitted_before.present? ||
      statuses.present?
  end

  def index_path_without_filter(filter:, value: nil)
    without_filter = compacted_attributes.merge(
      filter => compacted_attributes[filter].reject { |filter_value| filter_value == value },
    )

    claims_support_claims_path(
      params: { claims_support_claims_filter_form: without_filter },
    )
  end

  def index_path_without_submitted_dates(filter)
    without_filter = compacted_attributes.except(
      "#{filter}(1i)",
      "#{filter}(2i)",
      "#{filter}(3i)",
    )

    claims_support_claims_path(
      params: { claims_support_claims_filter_form: without_filter },
    )
  end

  def clear_filters_path
    filter_params = search.present? ? { claims_support_claims_filter_form: { search: } } : {}

    claims_support_claims_path(
      params: filter_params,
    )
  end

  def clear_search_path
    claims_support_claims_path(
      params: { claims_support_claims_filter_form: compacted_attributes.except("search") },
    )
  end

  def schools
    @schools ||= Claims::School.find(school_ids)
  end

  def providers
    @providers ||= Claims::Provider.find(provider_ids)
  end

  def query_params
    {
      search:,
      search_school:,
      search_provider:,
      school_ids:,
      provider_ids:,
      submitted_after:,
      submitted_before:,
      statuses:,
    }
  end

  def submitted_after
    Date.new(
      attributes["submitted_after(1i)"].to_i, # year
      attributes["submitted_after(2i)"].to_i, # month
      attributes["submitted_after(3i)"].to_i, # day
    )
  rescue Date::Error
    nil
  end

  def submitted_before
    Date.new(
      attributes["submitted_before(1i)"].to_i, # year
      attributes["submitted_before(2i)"].to_i, # month
      attributes["submitted_before(3i)"].to_i, # day
    )
  rescue Date::Error
    nil
  end

  private

  def compacted_attributes
    @compacted_attributes ||= attributes.compact_blank
  end
end
