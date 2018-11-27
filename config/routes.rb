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
  scope :game do
    post 'warp', to: 'game#warp'
    post 'jump', to: 'game#jump'
    get 'local_players', to: 'game#local_players'
    get 'ship_info', to: 'game#ship_info'
    get 'player_info', to: 'game#player_info'
  end
  
  # User
  scope :user do
    get 'info/:id', to: 'users#info'
    post 'update_bio', to: 'users#update_bio'
  end
  
  # Mails
  resources :game_mails, only: [:index, :new, :create, :show], path: 'mails'
  
  # Station
  scope :stations do
    post 'dock', to: 'stations#dock'
    post 'undock', to: 'stations#undock'
    post 'buy', to: 'stations#buy'
    post 'store', to: 'stations#store'
    post 'load', to: 'stations#load'
  end
  get '/station', to: 'stations#index'
  
  # Map
  get '/map', to: 'static_pages#map'
  
  # Assets
  get '/assets', to: 'game#assets'
  
  # Ships
  get '/ship', to: 'ships#index'
  scope :ship do
    post 'activate', to: 'ships#activate'
    post 'target', to: 'ships#target'
    post 'untarget', to: 'ships#untarget'
    get 'cargohold', to: 'ships#cargohold'
    post 'eject_cargo', to: 'ships#eject_cargo'
  end
  
  # Asteroids
  scope :asteroid do
    post 'mine', to: 'asteroids#mine'
    post 'stop_mine', to: 'asteroids#stop_mine'
  end
  
  # NPCs
  scope :npc do
    post 'target', to: 'npcs#target'
    post 'untarget', to: 'npcs#untarget'
  end
  
  # Structures
  scope :structure do
    post 'open_container', to: 'structures#open_container'
    post 'pickup_cargo', to: 'structures#pickup_cargo'
    post 'attack', to: 'structures#attack'
  end
  
  # Friends
  get 'friends', to: 'friends#index'
  scope :friends do
    post 'add_friend', to: 'friends#add_friend'
    post 'accept_request', to: 'friends#accept_request'
    post 'remove_friend', to: 'friends#remove_friend'
    post 'search', to: 'friends#search'
  end
  
  # Chat
  scope :chat do
    post 'join', to: 'chat_rooms#join'
    post 'create', to: 'chat_rooms#create'
    post 'leave', to: 'chat_rooms#leave'
    post 'start_conversation', to: 'chat_rooms#start_conversation'
  end
  
  # Fleets
  scope :fleet do
    post 'invite', to: 'fleets#invite'
    post 'accept_invite', to: 'fleets#accept_invite'
    post 'remove', to: 'fleets#remove'
  end
  
  # Equipment
  scope :equipment do
    post 'update', to: 'equipment#update'
    post 'switch', to: 'equipment#switch'
  end
  
  # ActionCable
  mount ActionCable.server => '/cable'
  
end
