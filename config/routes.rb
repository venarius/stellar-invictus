Rails.application.routes.draw do
  devise_for :users, path: '', path_names: { sign_in: 'connect', sign_out: 'disconnect', sign_up: 'enlist', edit: 'pilot' }
  
  # Static Pages
  root 'static_pages#home'
  get '/about', to: 'static_pages#about'
  get '/credits', to: 'static_pages#credits'
  get '/nojs', to: 'static_pages#nojs'
  
  # Factions
  resources :factions, only: [:index]
  scope :factions do
    post 'choose', to: 'factions#choose_faction', as: :choose_faction
  end
  
  # Game
  get '/game', to: 'game#index'
  post '/game/warp', to: 'game#warp'
  post '/game/jump', to: 'game#jump'
  get 'game/local_players', to: 'game#local_players'
  get 'game/ship_info', to: 'game#ship_info'
  
  # User
  get '/user/info/:id', to: 'users#info'
  
  # Mails
  resources :game_mails, only: [:index, :new, :create, :show], path: 'mails'
  
  # Station
  scope :stations do
    post 'dock', to: 'stations#dock'
    post 'undock', to: 'stations#undock'
    post 'buy', to: 'stations#buy'
  end
  get '/station', to: 'stations#index'
  
  # Map
  get '/map', to: 'static_pages#map'
  
  # Ships
  get '/ship', to: 'ships#index'
  scope :ship do
    post 'activate', to: 'ships#activate'
    post 'target', to: 'ships#target'
    post 'attack', to: 'ships#attack'
  end
  
  # Asteroids
  scope :asteroid do
    post 'mine', to: 'asteroids#mine'
    post 'stop_mine', to: 'asteroids#stop_mine'
  end
  
  # ActionCable
  mount ActionCable.server => '/cable'
  
end
