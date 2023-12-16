class AddIndexToUsersOnEmailAndService < ActiveRecord::Migration[7.1]
  def change
    remove_index :users, :email
    add_index :users, %i[service email], unique: true
  end
end
