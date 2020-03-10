Rails.application.routes.draw do
  devise_for :user

  match '/v0/*path', to: 'api#cors_preflight', via: [:options]
  get 'status' => 'status#status'

  get 'auth/login', to: 'auth#new', as: 'saml_login'
  post 'saml/auth/callback', to: 'auth#callback', as: 'saml_callback'
  get 'saml/metadata', to: 'auth#metadata'

  root 'application#home'

  # For active? helper
  get '/dashboards' => 'dashboards#index'
  post '/dashboards/build' => 'dashboards#build', as: :dashboard_build
  get '/dashboards/export/:csv_type' => 'dashboards#export', as: :dashboard_export, defaults: { format: 'csv' }
  get '/dashboards/api_fetch/:csv_type' => 'dashboards#api_fetch', as: :dashboard_api_fetch
  get '/dashboards/export/institutions/:number' => 'dashboards#export_version', as: :dashboard_export_version, defaults: { format: 'csv' }
  post '/dashboards/push' => 'dashboards#push', as: :dashboard_push

  resources :uploads, except: [:new, :destroy, :edit, :update] do
    get '(:csv_type)' => 'uploads#new', on: :new, as: ''
  end

  get '/crosswalk_issues/partials' => 'crosswalk_issues#partials', as: :crosswalk_issues_partials
  get '/crosswalk_issues/partials/:id' => 'crosswalk_issues#show_partial', as: :crosswalk_issues_partials_show
  post '/crosswalk_issues/partials' => 'crosswalk_issues#resolve_partial', as: :crosswalk_issues_resolve_partial

  get '/crosswalk_issues/orphans' => 'crosswalk_issues#orphans', as: :crosswalk_issues_orphans

  get '/archives' => 'archives#index'
  get '/archives/export/:csv_type/:number' => 'archives#export', as: :archives_export, defaults: { format: 'csv' }
  get '/calculator_constants' => 'calculator_constants#index'
  post '/calculator_constants' => 'calculator_constants#update', as: :calculator_constants_update

  resources :storages, only: [:index, :edit, :update, :show] do
    get 'download' => 'storages#download', on: :member, defaults: { format: 'csv' }
  end

  namespace :v0, defaults: { format: 'json' } do
    get '/calculator/constants' => 'calculator_constants#index'

    resources :institutions, only: [:index, :show] do
      get :autocomplete, on: :collection
      get :children, on: :member
    end

    resources :institution_programs, only: [:index] do
      get :autocomplete, on: :collection
    end

    resources :yellow_ribbon_programs, only: :index

    resources :zipcode_rates, only: :show
  end
end
