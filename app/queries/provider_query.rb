class ProviderQuery < ApplicationQuery
  MAX_LOCATION_DISTANCE = 50

  def call
    scope = Provider
    order_condition(scope)
  end

  private

  def provider_ids_near_location(location_coordinates)
    Provider.near(
      location_coordinates,
      MAX_LOCATION_DISTANCE,
      order: :distance,
    ).map(&:id)
  end

  def order_condition(scope)
    if params[:location_coordinates].present?
      provider_ids = provider_ids_near_location(
        params[:location_coordinates],
      )

      scope.where(id: provider_ids)
        .order_by_ids(provider_ids)
    else
      scope.order_by_name
    end
  end
end
