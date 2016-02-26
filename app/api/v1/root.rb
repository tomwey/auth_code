require 'v1/helpers'
require 'v1/entities'
require 'v1/shared_params'
# require 'v1/welcome'

module V1
  class Root < Grape::API
  
    version 'v1'
    
    helpers V1::APIHelpers
    helpers V1::SharedParams
    
    mount V1::Welcome
  
  end
end
