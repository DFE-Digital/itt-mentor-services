# == Schema Information
#
# Table name: schools
#
#  id         :uuid             not null, primary key
#  claims     :boolean          default(FALSE)
#  placements :boolean          default(FALSE)
#  urn        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_schools_on_claims      (claims)
#  index_schools_on_placements  (placements)
#  index_schools_on_urn         (urn) UNIQUE
#
class Claims::School < School
  default_scope { claims }
end
