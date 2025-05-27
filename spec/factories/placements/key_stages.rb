# == Schema Information
#
# Table name: key_stages
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :key_stage, class: "Placements::KeyStage" do
  end
end
