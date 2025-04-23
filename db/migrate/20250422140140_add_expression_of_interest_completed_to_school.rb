class AddExpressionOfInterestCompletedToSchool < ActiveRecord::Migration[7.2]
  def change
    add_column :schools, :expression_of_interest_completed, :boolean, default: false
  end
end
