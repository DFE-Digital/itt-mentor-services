class RemoveServiceFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :service, :enum, enum_type: "service", null: false
  end
end
