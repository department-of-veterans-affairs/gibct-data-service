Rails.application.routes.draw do
  devise_for :user

  match '/v0/*path', to: 'api#cors_preflight', via: [:options]
  match '/v1/*path', to: 'api#cors_preflight', via: [:options]
  get 'status' => 'status#status'

  get 'auth/login', to: 'auth#new', as: 'saml_login'
  post 'saml/auth/callback', to: 'auth#callback', as: 'saml_callback'
  get 'saml/metadata', to: 'auth#metadata'

  root 'application#home'

  # For active? helper
  get '/dashboards' => 'dashboards#index'
  post '/dashboards/build' => 'dashboards#build', as: :dashboard_build
  post '/dashboards/unlock_generate_button' => 'dashboards#unlock_generate_button', as: :dashboard_unlock_generate_button
  get '/dashboards/export/:csv_type' => 'dashboards#export', as: :dashboard_export, defaults: { format: 'csv' }
  get '/dashboards/api_fetch/:csv_type' => 'dashboards#api_fetch', as: :dashboard_api_fetch
  get '/dashboards/export/institutions/:number' => 'dashboards#export_version', as: :dashboard_export_version, defaults: { format: 'csv' }
  get '/dashboards/export_ungeocodables' => 'dashboards#export_ungeocodables', as: :dashboard_export_ungeocodables, defaults: { format: 'csv' }
  get '/dashboards/export_orphans' => 'dashboards#export_orphans', as: :dashboard_export_orphans, defaults: { format: 'csv' }
  get '/dashboards/export_partials' => 'dashboards#export_partials', as: :dashboard_export_partials, defaults: { format: 'csv' }
  get '/dashboards/export_unaccrediteds' => 'dashboards#export_unaccrediteds', as: :dashboard_export_unaccrediteds, defaults: { format: 'csv' }
  get '/dashboards/geocoding_issues' => 'dashboards#geocoding_issues', as: :dashboard_geocoding_issues
  get '/dashboards/accreditation_issues' => 'dashboards#accreditation_issues', as: :dashboard_accreditation_issues
  get '/unlock_fetches' => 'dashboards#unlock_fetches', as: :unlock_fetches

  get 'preview_statuses/poll' => 'preview_statuses#poll', as: :poll_preview_status

  resources :accreditation_type_keywords, only: [:index, :new, :create, :destroy]

  resources :uploads, except: [:new, :destroy, :edit, :update] do
    get '(:csv_type)' => 'uploads#new', on: :new, as: ''
  end

  get '/groups', to: redirect('/uploads')
  resources :groups, except: [:new, :destroy, :edit, :update] do
    get '(:group_type)' => 'groups#new', on: :new, as: ''
  end

  get '/crosswalk_issues/partials' => 'crosswalk_issues#partials', as: :crosswalk_issues_partials
  get '/crosswalk_issues/partials/:id' => 'crosswalk_issues#show_partial', as: :crosswalk_issues_partials_show
  post '/crosswalk_issues/partials' => 'crosswalk_issues#resolve_partial', as: :crosswalk_issues_resolve_partial

  get '/crosswalk_issues/orphans' => 'crosswalk_issues#orphans', as: :crosswalk_issues_orphans

  get '/archives' => 'archives#index'
  get '/archives/export/:csv_type/:number' => 'archives#export', as: :archives_export, defaults: { format: 'csv' }

  resources :calculator_constants, only: [:index] do
    post :update, on: :collection
    get 'export' => 'calculator_constants#export', on: :collection, defaults: { format: 'csv' }
  end

  resources :yellow_ribbon_degree_level_translations, except: [:create, :new, :destroy], path: :degree_levels
  mount MissionControl::Jobs::Engine, at: "/jobs"

  post '/calculator_constants/apply_rate_adjustments/:rate_adjustment_id', to: 'calculator_constants#apply_rate_adjustments'

  resources :rate_adjustments, only: [] do
    post :update, on: :collection
    post :build, on: :collection
  end

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

  namespace :v1, defaults: { format: 'json' } do
    get '/calculator/constants' => 'calculator_constants#index'
    get '/institutions', to: 'institutions#facility_codes', constraints: lambda { |request| request.query_parameters.key?(:facility_codes) }
    get '/institutions', to: 'institutions#program', constraints: lambda { |request| 
      request.query_parameters.key?(:description) && 
      request.query_parameters.key?(:latitude) && 
      request.query_parameters.key?(:longitude)
    }
    get '/institutions', to: 'institutions#location', constraints: lambda { |request| request.query_parameters.key?(:latitude) && request.query_parameters.key?(:longitude) }

    resources :institutions, only: [:index, :show] do
      get :autocomplete, on: :collection
      get :children, on: :member
    end

    resources :institution_programs, only: [:index] do
      get :autocomplete, on: :collection
    end

    resources :yellow_ribbon_programs, only: :index

    resources :zipcode_rates, only: :show

    namespace :lcpe do
      resources :lacs, only: [:index, :show]
      resources :exams, only: [:index, :show]
    end    

    resources :version_public_exports, only: [:show], path: :public_exports
  end
end
