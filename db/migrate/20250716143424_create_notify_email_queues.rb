class CreateNotifyEmailQueues < ActiveRecord::Migration[8.0]
  def change
    create_table :notify_email_queues do |t|
      t.string :recipient, null: false
      t.string :subject, null: false
      t.text :body, null: false
      t.integer :status, null: false, default: 0
      t.datetime :sent_at
      t.text :error

      t.timestamps
    end

    add_index :notify_email_queues, :status
    add_index :notify_email_queues, :recipient
    add_index :notify_email_queues, :sent_at
  end
end
