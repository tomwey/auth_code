class CreateSmsConfigs < ActiveRecord::Migration
  def change
    create_table :sms_configs do |t|
      t.string :app_name, null: false
      t.string :sp_provider, null: false
      t.string :sp_url
      t.string :sp_api_key
      t.string :api_key
      t.string :sms_tpl_text

      t.timestamps null: false
    end
    
    add_index :sms_configs, :api_key, unique: true
  end
end
