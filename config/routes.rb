Rails.application.routes.draw do
  resources :vsocs
  resources :p911_yrs
  resources :p911_tfs
  resources :arf_gi_bills
  resources :scorecards
  resources :accreditations
  resources :eight_keys
  resources :crosswalks
  resources :versions
  resources :weams
  devise_for :user

  # For active? helper
  get "/dashboards", controller: :dashboards, action: :index
  root 'dashboards#index'

  resource :weams
end
