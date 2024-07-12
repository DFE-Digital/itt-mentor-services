# == Schema Information
#
# Table name: claim_windows
#
#  id               :uuid             not null, primary key
#  discarded_at     :date
#  ends_on          :date
#  starts_on        :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  academic_year_id :uuid             not null
#
# Indexes
#
#  index_claim_windows_on_academic_year_id  (academic_year_id)
#  index_claim_windows_on_discarded_at      (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#
require "rails_helper"

RSpec.describe Claims::ClaimWindow, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
