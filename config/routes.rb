Rails.application.routes.draw do
  
  root 'home#index'
  
  require 'dispatch'
  mount API::Dispatch => '/api'
end
