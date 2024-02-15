class RemoveSchoolIdFromMentor < ActiveRecord::Migration[7.1]
  def change
    remove_column :mentors, :school_id, :uuid
  end
end
