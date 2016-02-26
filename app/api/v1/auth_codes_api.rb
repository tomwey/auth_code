module V1
  class AuthCodesAPI < Grape::API
    
    resource :auth_codes do
      desc "获取验证码"
      params do
        requires :mobile, type: String, desc: "手机号"
        requires :api_key, type: String, desc: "API Key"
        optional :code_length, type: Integer, desc: "验证码长度，4-6位长度，默认值为4"
      end
      post :fetch do
        
        sms_config = SmsConfig.find_by(api_key: params[:api_key])
        return render_error(1000, "不正确的api key") if sms_config.blank?
        
        mobile = params[:mobile].to_s
        
        return render_error(1001, "不正确的手机号") unless check_mobile(mobile)
        
        # 1分钟内多次发送验证码短信检测
        key = "#{mobile}_key".to_sym
        if session[key] and ( ( Time.now.to_i - session[key].to_i ) < ( 60 + rand(3) ) )
          return render_error(1002, "同一手机号1分钟内只能获取一次验证码，请稍后重试")
        end
        session[key] = Time.now.to_i
        ###### end
        
        sms_config_id = sms_config.id
        
        # 同一手机一天最多获取5次验证码
        log = SendSmsLog.where('mobile = ? and sms_config_id = ?', mobile, sms_config_id).first
        if log.blank?
          dt = 0
          log = SendSmsLog.create!(mobile: mobile, first_sent_at: Time.now, sms_config_id: sms_config_id)
        else
          dt = Time.now.to_i - log.first_sent_at.to_i
          
          if dt > 24 * 3600 # 超过24小时重置发送记录
            log.send_total = 0
            log.first_sent_at = Time.now
            log.save!
          else
            # 24小时以内
            if log.send_total.to_i == 5 # 已经发送了5次
              return render_error(1003, "同一手机号24小时内只能获取5次验证码，请稍后再试")
            end
          end
        end
        
        # 获取验证码并发送短信
        code_length = params[:code_length].to_i
        if code_length < 4
          code_length = 4
        elsif code_length > 6
          code_length = 6
        end
        
        code = sms_config.auth_codes.where('mobile = ? and activated_at is null', mobile).first
        if code.blank? or code.code.length != code_length
          code = AuthCode.create_code!(mobile, code_length, sms_config_id)
        end
        return render_error(1004, "验证码生成错误，请重试") if code.blank?
        
        # 发短信
        tpl = sms_config.sms_tpl_text.blank? ? "您的验证码是{code}【{company}】" : sms_config.sms_tpl_text
        text = tpl.gsub('{code}', "#{code.code}")
        text = text.gsub('{company}', "#{sms_config.app_name}")
        RestClient.post(sms_config.sp_url, "apikey=#{sms_config.sp_api_key}&mobile=#{mobile}&text=#{text}") { |response, request, result, &block|
          resp = JSON.parse(response)
          if resp['code'] == 0
            # 发送成功，更新发送日志
            log.update_attribute(:send_total, log.send_total + 1)
            { code: 0, message: "ok" }
          else
            # 发送失败，更新每分钟发送限制
            session.delete(key)
            { code: -1, message: resp['msg'] }
          end
        }
        
      end # end post fetch
      
      desc "检查验证码是否有效"
      params do
        requires :mobile, type: String, desc: "手机号"
        requires :code,   type: String, desc: "收到的短信验证码"
        requires :api_key, type: String, desc: "api key"
      end
      get :check_valid do
        sms_config = SmsConfig.find_by(api_key: params[:api_key])
        return render_error(2001, "不正确的api key") if sms_config.blank?
        ac = sms_config.auth_codes.where('mobile = ? and code = ? and activated_at is null', params[:mobile], params[:code]).first
        { code: 0, message: 'ok', data: { valid: !ac.blank? } }
      end # end get check_valid
      
      desc "让验证码失效"
      params do
        requires :mobile, type: String, desc: "手机号"
        requires :code,   type: String, desc: "收到的短信验证码"
        requires :api_key, type: String, desc: "api key"
      end
      post :invalid do
        sms_config = SmsConfig.find_by(api_key: params[:api_key])
        return render_error(2001, "不正确的api key") if sms_config.blank?
        
        ac = sms_config.auth_codes.where('mobile = ? and code = ? and activated_at is null', params[:mobile], params[:code]).first
        return render_error(2002, "验证码无效") if ac.blank?
        
        if ac.update_attribute(:activated_at, Time.now)
          render_json_no_data
        else
          render_error(2003, "验证码验证失败")
        end
        
      end # end post invalid
      
    end # end resource auth_codes
  end
end