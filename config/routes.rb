Rails.application.routes.draw do
  require 'dispatch'
  mount API::Dispatch => '/api'
end
