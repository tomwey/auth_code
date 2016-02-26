module V1
  module Entities
    class Base < Grape::Entity
      format_with(:null) { |v| v.blank? ? "" : v }
      format_with(:chinese_datetime) { |v| v.blank? ? "" : v.strftime('%Y-%m-%d %H:%M:%S') }
      expose :id
    end # end Base
  
    class SmsConfig < Base
      expose :app_name, :sp_provider, :api_key
      expose :sms_tpl_text, format_with: :null
      expose :created_at, format_with: :chinese_datetime
    end
    
  end
end
