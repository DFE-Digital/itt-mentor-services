# == Schema Information
#
# Table name: samplings
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :samplings, class: "Claims::Sampling" do
  end
end
