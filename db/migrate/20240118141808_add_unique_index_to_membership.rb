class AddUniqueIndexToMembership < ActiveRecord::Migration[7.1]
  def change
    add_index :memberships, %i[user_id organisation_id], unique: true
  end
end
