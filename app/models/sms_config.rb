class SmsConfig < ActiveRecord::Base
  validates :app_name, :sp_provider, presence: true
  validates_uniqueness_of :api_key
  
  has_many :auth_codes
  
  before_create :generate_api_key
  def generate_api_key
    self.api_key = SecureRandom.uuid.gsub('-', '') if self.api_key.blank?
  end
  
end

# create_table :sms_configs do |t|
#   t.string :app_name, null: false
#   t.string :sp_url
#   t.string :sp_api_key
#   t.string :api_key
#   t.string :sms_tpl_text
#
#   t.timestamps null: false
# end
#
# add_index :sms_configs, :api_key, unique: true
