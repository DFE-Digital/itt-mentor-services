# == Schema Information
#
# Table name: clawbacks
#
#  id            :uuid             not null, primary key
#  downloaded_at :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :clawback, class: Claims::Clawback do
    claims { build_list(:claim, 3, :clawback_in_progress) }
    csv_file { file_fixture("example-clawbacks.csv") }
  end
end
