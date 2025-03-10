class AddTrainedToMentor < ActiveRecord::Migration[7.2]
  def change
    add_column :mentors, :trained, :boolean, null: true
  end
end
