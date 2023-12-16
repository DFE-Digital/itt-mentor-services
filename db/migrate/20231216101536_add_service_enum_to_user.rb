class AddServiceEnumToUser < ActiveRecord::Migration[7.1]
  def change
    create_enum :service, %w[claims placements]
    add_column :users, :service, :enum, enum_type: "service", null: false # rubocop:disable  Rails/NotNullColumn
  end
end
