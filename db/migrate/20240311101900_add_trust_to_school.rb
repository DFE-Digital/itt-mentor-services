class AddTrustToSchool < ActiveRecord::Migration[7.1]
  def change
    add_reference :schools, :trust, null: true, foreign_key: true, type: :uuid
  end
end
