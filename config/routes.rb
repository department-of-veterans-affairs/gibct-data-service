Rails.application.routes.draw do
  devise_for :user

  # For active? helper
  get '/dashboards' => 'dashboards#index'
  root 'dashboards#index'

  resources :uploads, except: :destroy

  namespace :v0, defaults: { format: 'json' } do
    get '/calculator/constants' => 'calculator_constants#index'

    resources :institutions, only: [:index, :show] do
      get :autocomplete, on: :collection
    end
  end
end
