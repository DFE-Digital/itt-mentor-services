class AddColumnsToClaims < ActiveRecord::Migration[7.1]
  def change
    add_column(:claims, :reference, :string)
    add_index(:claims, :reference, unique: true)
    add_column(:claims, :submitted_at, :datetime)
  end
end
