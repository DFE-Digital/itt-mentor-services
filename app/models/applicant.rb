# == Schema Information
#
# Table name: applicants
#
#  id            :uuid             not null, primary key
#  address1      :string
#  address2      :string
#  address3      :string
#  address4      :string
#  email_address :string
#  first_name    :string
#  last_name     :string
#  latitude      :float
#  longitude     :float
#  postcode      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  apply_id      :string
#  provider_id   :uuid             not null
#
# Indexes
#
#  index_applicants_on_apply_id                (apply_id) UNIQUE
#  index_applicants_on_latitude                (latitude)
#  index_applicants_on_latitude_and_longitude  (latitude,longitude)
#  index_applicants_on_longitude               (longitude)
#  index_applicants_on_provider_id             (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#
class Applicant < ApplicationRecord
  belongs_to :provider

  extend Geocoder::Model::ActiveRecord

  ADDRESS_FIELDS = %w[address1 address2 address3 address4 postcode].freeze

  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  def address
    [
      *attributes.slice(*ADDRESS_FIELDS).values,
    ].compact.join(", ")
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def driving_duration(destination)
    matrix = GoogleMatrixApi.call(origin: self, destination:, travel_type: "driving")
    matrix.shortest_route_by_duration_to(matrix.destinations.first).duration_text
  end

  def transit_duration(destination)
    matrix = GoogleMatrixApi.call(origin: self, destination:, travel_type: "transit")
    matrix.shortest_route_by_duration_to(matrix.destinations.first).duration_text
  end

  private

  def address_changed?
    changed.any? { |attribute| ADDRESS_FIELDS.include?(attribute) }
  end
end
