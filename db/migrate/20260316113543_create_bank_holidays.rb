class CreateBankHolidays < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_holidays, id: :uuid do |t|
      t.string :title
      t.date :date
      t.timestamps
    end
  end
end
