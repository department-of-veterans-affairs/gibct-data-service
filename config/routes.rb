Rails.application.routes.draw do
  devise_for :user

  # For active? helper
  get "/dashboards", controller: :dashboards, action: :index
  root 'dashboards#index'

  resource :weams
end
