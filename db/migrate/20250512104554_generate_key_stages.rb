class GenerateKeyStages < ActiveRecord::Migration[7.2]
  def up
    Placements::KeyStage::VALID_NAMES.each do |name|
      Placements::KeyStage.find_or_create_by!(name:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
