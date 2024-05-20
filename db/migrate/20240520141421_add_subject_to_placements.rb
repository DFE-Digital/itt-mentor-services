class AddSubjectToPlacements < ActiveRecord::Migration[7.1]
  def change
    add_reference :placements, :subject, type: :uuid, foreign_key: true
  end
end
