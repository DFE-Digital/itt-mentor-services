class AddGrantConditionsToSchools < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :claims_grant_conditions_accepted_at, :datetime
    add_reference :schools, :claims_grant_conditions_accepted_by, type: :uuid, foreign_key: { to_table: :users }
  end
end
