Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :users
  get  '/clinic', controller: 'clinic', action: 'index'

  post '/patient/create_remote', controller:  'people', action:  'create_remote'
  get '/patient/create_remote', controller:  'people', action:  'create_remote'

  get  '/admin', controller: 'admin', action: 'index'
  get  '/login', controller: 'sessions', action: 'new'
  post '/logout', controller:  'sessions', action:  'destroy'
  get '/logout', controller: 'sessions', action: 'destroy'
  get '/location', to: "sessions#location"
  get '/encounters/new/:encounter_type', controller:  'encounters', action: 'new'
  post '/encounters/new/:encounter_type', controller:  'encounters', action: 'new'
  get '/encounters/new/:encounter_type/:id', controller: 'encounters', action: 'new'
  post '/encounters/new/:encounter_type/:id', controller: 'encounters', action: 'new'
  post '/user/create/:id', controller: 'user', action: 'create'
  post '/user/update/:id', controller: 'user', action: 'update'
  post '/user/change_password/:id', controller: 'user', action: 'change_password'
  post '/user/add_role/:id', controller: 'user', action: 'add_role'
  post '/user/delete_role/:id', controller: 'user', action: 'delete_role'

  resources :dispensations, collection: {quantities: :get}
  resources :barcodes, collection: {label: :get}
  resources :relationships, collection: {search: :get}
  resources :programs, collection: {locations: :get, workflows: :get, states: :get}
  resources :encounter_types
  resources :single_sign_on, collection: {get_token: [:get, :post], load_page: [:get, :post],single_sign_in: [:get, :post]}
  resource :session


  get '/:controller/:action/:id'
  get '/:controller/:action'
  post '/:controller/:action'

  root "people#index"
end
