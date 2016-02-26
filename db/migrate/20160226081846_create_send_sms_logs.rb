class CreateSendSmsLogs < ActiveRecord::Migration
  def change
    create_table :send_sms_logs do |t|
      t.string :mobile, null: false
      t.integer :send_total, default: 0
      t.datetime :first_sent_at
      t.integer :sms_config_id

      t.timestamps null: false
    end
    add_index :send_sms_logs, :sms_config_id
    add_index :send_sms_logs, [:mobile, :sms_config_id]
  end
end
