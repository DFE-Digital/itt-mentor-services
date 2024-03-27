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
#  index_applicants_on_apply_id     (apply_id) UNIQUE
#  index_applicants_on_latitude     (latitude)
#  index_applicants_on_longitude    (longitude)
#  index_applicants_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#
require "rails_helper"

RSpec.describe Applicant, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:provider) }
  end

  describe "geocoding" do
    before do
      stub_request(:get, "https://nominatim.openstreetmap.org/search?accept-language=en&addressdetails=1&format=json&q=MyString,%20MyString,%20MyString,%20MyString,%20MyString")
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "User-Agent" => "Ruby",
          },
        )
        .to_return(status: 200, body: "{}", headers: {})
    end

    let(:applicant) { build(:applicant) }

    it "geocodes the address" do
      expect(applicant).to receive(:geocode)
      applicant.save!
    end
  end
end
