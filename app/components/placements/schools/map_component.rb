class Placements::Schools::MapComponent < ApplicationComponent
  attr_reader :schools, :base_longitude, :base_latitude

  def initialize(schools:, base_longitude:, base_latitude:, provider: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @schools = schools
    @base_longitude = base_longitude
    @base_latitude = base_latitude
    @provider = provider
  end

  def map_id
    @provider.present? ? "#{@provider.id}_map" : SecureRandom.uuid
  end

  def render?
    !schools.pluck(:longitude, :latitude).compact.flatten.uniq.all?(nil)
  end
end
