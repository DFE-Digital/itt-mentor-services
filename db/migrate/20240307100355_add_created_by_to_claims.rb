class AddCreatedByToClaims < ActiveRecord::Migration[7.1]
  def change
    add_reference :claims, :created_by, polymorphic: true, type: :uuid
  end
end
