class AddSupportUserToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :support_user, :boolean, default: false
  end
end
