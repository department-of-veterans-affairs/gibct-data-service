Rails.application.routes.draw do
  resources :csv_files
  resources :data_csvs
  resources :versions
  devise_for :user

  # For active? helper
  get "/dashboards", controller: :dashboards, action: :index
  root 'dashboards#index'

  resource :weams
  resources :crosswalks
end
