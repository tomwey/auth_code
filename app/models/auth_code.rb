class AuthCode < ActiveRecord::Base
  belongs_to :sms_config
  
  def self.create_code!(mobile, code_length, sms_config_id)
    
    str_length = code_length + 1
    code_str = rand.to_s[2..str_length]
    
    code = AuthCode.create!(code: code_str, mobile: mobile, sms_config_id: sms_config_id)
    code
  end
  
end
