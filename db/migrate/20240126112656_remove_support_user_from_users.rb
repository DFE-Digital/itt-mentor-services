class RemoveSupportUserFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :support_user, :boolean, default: false
  end
end
