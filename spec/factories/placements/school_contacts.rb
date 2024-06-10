# == Schema Information
#
# Table name: school_contacts
#
#  id            :uuid             not null, primary key
#  email_address :string           not null
#  first_name    :string
#  last_name     :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  school_id     :uuid             not null
#
# Indexes
#
#  index_school_contacts_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
FactoryBot.define do
  factory :school_contact, class: "Placements::SchoolContact" do
    association :school, factory: :placements_school

    name { "Placement Coordinator" }
    first_name { "Placement" }
    last_name { "Coordinator" }
    email_address { "placement_coordinator@example.school" }
  end
end
