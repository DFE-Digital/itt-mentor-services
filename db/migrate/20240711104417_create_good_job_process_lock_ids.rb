class CreateGoodJobProcessLockIds < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        # Ensure this incremental update migration is idempotent
        # with monolithic install migration.
        return if connection.column_exists?(:good_jobs, :locked_by_id)
      end
    end

    safety_assured do
      change_table :good_jobs, bulk: true do |t|
        t.uuid :locked_by_id
        t.datetime :locked_at
      end
    end

    add_column :good_job_executions, :process_id, :uuid
    add_column :good_job_processes, :lock_type, :integer, limit: 2
  end
end
