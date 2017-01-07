Rails.application.routes.draw do
  resources :crosswalks
  resources :versions
  resources :weams
  devise_for :user

  # For active? helper
  get "/dashboards", controller: :dashboards, action: :index
  root 'dashboards#index'

  resource :weams
end
