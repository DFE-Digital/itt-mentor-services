class RemoveTrainingWithDisabilitiesFromSchool < ActiveRecord::Migration[7.1]
  def change
    # This column has never been synced via GIAS and is not included in the importer, therefore it is safe to remove.
    safety_assured { remove_column :schools, :training_with_disabilities, :string }
  end
end
