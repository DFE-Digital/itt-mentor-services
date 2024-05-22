# frozen_string_literal: true

class BackfillPlacementSubject < ActiveRecord::Migration[7.1]
  def up
    Placement.find_each do |placement|
      subject = placement.subjects.last
      placement.update!(subject:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
