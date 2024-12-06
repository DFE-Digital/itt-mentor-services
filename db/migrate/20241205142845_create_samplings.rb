class CreateSamplings < ActiveRecord::Migration[7.2]
  def change
    create_table :samplings, id: :uuid, &:timestamps
  end
end
