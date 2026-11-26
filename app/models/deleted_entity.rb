# == Schema Information
#
# Table name: deleted_entities
#
#  id              :uuid             not null, primary key
#  deleted_records :jsonb            not null
#  entity_name     :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  entity_id       :string           not null
#

class DeletedEntity < ApplicationRecord
end
