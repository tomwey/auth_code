module V1
  class SmsConfigsAPI < Grape::API
    resource :sms_configs do
      desc '创建一个短信发送配置'
      params do
        requires :app_name,     type: String, desc: "app名字"
        requires :sp_provider,  type: String, desc: "短信服务提供商名字"
        optional :sp_url,       type: String, desc: "短信服务商提供的地址"
        optional :sp_api_key,   type: String, desc: "短信服务商接口访问key"
        optional :sms_tpl_text, type: String, desc: "验证码模板内容"
      end
      post :create do
        sc = SmsConfig.create!(app_name: params[:app_name], 
                               sp_provider: params[:sp_provider],
                               sp_url: params[:sp_url],
                               sp_api_key: params[:sp_api_key],
                               sms_tpl_text: params[:sms_tpl_text],
                               )
        render_json(sc, V1::Entities::SmsConfig)
      end # end post create
      
      desc '获取一个短信配置'
      params do
        requires :api_key, type: String, desc: "api key"
      end
      get '/:api_key' do
        sc = SmsConfig.find_by(api_key: params[:api_key])
        
        render_json(sc, V1::Entities::SmsConfig)
      end # end get api_key
      
    end # end resource sms_configs
  end
end