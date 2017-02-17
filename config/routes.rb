Rails.application.routes.draw do
  match '/v0/*path', to: 'api#cors_preflight', via: [:options]

  devise_for :user

  # For active? helper
  get '/dashboards' => 'dashboards#index'
  root 'dashboards#index'

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
