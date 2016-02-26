module V1
  module SharedParams
    extend Grape::API::Helpers
  
    # 分页参数
    # 使用例子：
    #   params do
    #     use :pagination
    #   end
    params :pagination do
      optional :page, type: Integer, desc: "当前页"
      optional :size, type: Integer, desc: "分页大小，默认值为：15"
    end # end pagination params
  
  end
end

