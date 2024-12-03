class AddSamplingReasonToClaim < ActiveRecord::Migration[7.2]
  def change
    add_column :claims, :sampling_reason, :text
  end
end
