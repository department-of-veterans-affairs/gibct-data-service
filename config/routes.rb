Rails.application.routes.draw do
  resources :complaints
  resources :ipeds_ic_pies
  resources :ipeds_ic_ays
  resources :ipeds_hds
  resources :ipeds_ics
  resources :settlements
  resources :hcms
  resources :mous
  resources :sec702_schools
  resources :sec702s
  resources :svas
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
