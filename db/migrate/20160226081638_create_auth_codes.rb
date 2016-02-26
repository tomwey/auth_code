class CreateAuthCodes < ActiveRecord::Migration
  def change
    create_table :auth_codes do |t|
      t.string :code, limit: 6, null: false
      t.string :mobile,         null: false
      t.datetime :activated_at
      t.integer :sms_config_id

      t.timestamps null: false
    end
    
    add_index :auth_codes, :code
    add_index :auth_codes, :mobile
    add_index :auth_codes, :sms_config_id
    
  end
end
