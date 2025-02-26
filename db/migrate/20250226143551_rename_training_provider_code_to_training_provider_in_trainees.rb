class RenameTrainingProviderCodeToTrainingProviderInTrainees < ActiveRecord::Migration[7.2]
  def change
    safety_assured { rename_column :trainees, :training_provider_code, :training_provider }
  end
end
