module V1
  class Welcome < Grape::API
    # params do
    #   use :pagination
    # end
    get :foo do
      { foo: '你好' }
    end
  end
end