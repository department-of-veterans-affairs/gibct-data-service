Rails.application.routes.draw do
  devise_for :user

  match '/v0/*path', to: 'api#cors_preflight', via: [:options]
  get 'status' => 'status#status'

  root 'dashboards#index'

  # For active? helper
  get '/dashboards' => 'dashboards#index'
  post '/dashboards/build' => 'dashboards#build', as: :dashboard_build
  get '/dashboards/export/:csv_type' => 'dashboards#export', as: :dashboard_export, defaults: { format: 'csv' }
  post '/dashboards/push' => 'dashboards#push', as: :dashboard_push

  resources :uploads, except: [:new, :destroy, :edit, :update] do
    get '(:csv_type)' => 'uploads#new', on: :new, as: ''
  end

  namespace :v0, defaults: { format: 'json' } do
    get '/calculator/constants' => 'calculator_constants#index'

    resources :institutions, only: [:index, :show] do
      get :autocomplete, on: :collection
    end
  end
end
