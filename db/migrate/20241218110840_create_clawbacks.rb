class CreateClawbacks < ActiveRecord::Migration[7.2]
  def change
    create_table :clawbacks, id: :uuid, &:timestamps
  end
end
