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
FactoryBot.define do
  factory :applicant do
    apply_id { "C21109" }
    first_name { "Jane" }
    last_name { "Doe" }
    email_address { "jane.doe@example.com" }
    address1 { "Address 1" }
    address2 { "Address 2" }
    address3 { "Address 3" }
    address4 { "Address 4" }
    postcode { "Postcode" }

    association :provider, factory: :provider
  end
end
