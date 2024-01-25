class AddIndexToUsersOnEmailAndType < ActiveRecord::Migration[7.1]
  def change
    add_index :users, %i[type email], unique: true
  end
end
