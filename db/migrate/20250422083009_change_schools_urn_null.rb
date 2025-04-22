class ChangeSchoolsUrnNull < ActiveRecord::Migration[7.2]
  def change
    change_column_null :schools, :urn, true
  end
end
