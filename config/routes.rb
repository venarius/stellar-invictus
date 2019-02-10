Rails.application.routes.draw do
  devise_for :users, path: '', path_names: { sign_in: 'connect', sign_out: 'disconnect', sign_up: 'enlist', edit: 'pilot' }, controllers: { registrations: "registrations" }
  
  # Static Pages
  root 'static_pages#home'
  get '/credits', to: 'static_pages#credits'
  get '/nojs', to: 'static_pages#nojs'
  get '/support', to: 'static_pages#support'
  get '/donate', to: 'static_pages#donate'
  post '/support_ticket/create', to: 'static_pages#create_support_ticket', as: :create_support_ticket
  
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
    get 'chat', to: 'game#chat'
    get 'system_card', to: 'game#system_card'
    get 'locations_card', to: 'game#locations_card'
  end
  
  # User
  scope :user do
    get 'info/:id', to: 'users#info'
    post 'update_bio', to: 'users#update_bio'
    post 'place_bounty', to: 'users#place_bounty'
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
  scope :ship do
    post 'activate', to: 'ships#activate'
    post 'target', to: 'ships#target'
    post 'untarget', to: 'ships#untarget'
    get 'cargohold', to: 'ships#cargohold'
    post 'eject_cargo', to: 'ships#eject_cargo'
    get 'info', to: 'ships#info'
    post 'insure', to: 'ships#insure'
    post 'custom_name', to: 'ships#custom_name'
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
    post 'abandoned_ship', to: 'structures#abandoned_ship'
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
    post 'search', to: 'chat_rooms#search'
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
    get 'info', to: 'equipment#info'
  end
  
  # Market
  scope :market do
    get 'list', to: 'market#list'
    get 'search', to: 'market#search'
    post 'buy', to: 'market#buy'
    post 'appraisal', to: 'market#appraisal'
    post 'sell', to: 'market#sell'
  end
  
  # Systems
  scope :system do
    get 'info', to: 'systems#info'
    post 'route', to: 'systems#route'
    post 'clear_route', to: 'systems#clear_route'
    post 'scan', to: 'systems#scan'
  end
  
  # Missions
  scope :mission do
    get 'info', to: 'missions#info'
    post 'accept', to: 'missions#accept'
    post 'finish', to: 'missions#finish'
    get 'popup', to: 'missions#popup'
    post 'abort', to: 'missions#abort'
  end
  
  # Blueprints
  scope :blueprint do
    post 'buy', to: 'blueprints#buy'
    get 'modal', to: 'blueprints#modal'
  end
  
  # Factory
  scope :factory do
    get 'modal', to: 'factories#modal'
    post 'craft', to: 'factories#craft'
  end
  
  # Corporation
  resources :corporations, only: [:index, :new, :create], path: 'corporation'
  scope :corporation do
    post 'update_motd', to: 'corporations#update_motd'
    post 'update_corporation', to: 'corporations#update_corporation'
    post 'kick_user', to: 'corporations#kick_user'
    get 'change_rank_modal', to: 'corporations#change_rank_modal'
    post 'change_rank', to: 'corporations#change_rank'
    post 'deposit_credits', to: 'corporations#deposit_credits'
    post 'withdraw_credits', to: 'corporations#withdraw_credits'
    get 'info', to: 'corporations#info'
    get 'apply_modal', to: 'corporations#apply_modal'
    post 'apply', to: 'corporations#apply'
    post 'accept_application', to: 'corporations#accept_application'
    post 'reject_application', to: 'corporations#reject_application'
    post 'disband', to: 'corporations#disband'
    post 'search', to: 'corporations#search'
    get 'sort_roster', to: 'corporations#sort_roster'
  end
  
  # Community
  scope :community do
    get '/', to: 'communities#index', as: :community
  end
  
  # Discourse
  get 'discourse/sso' => 'discourse_sso#sso'
  
  # Admin
  scope :admin do
    get '/', to: 'admin#index', as: :admin
    post 'search', to: 'admin#search'
    post 'teleport', to: 'admin#teleport'
    post 'set_credits', to: 'admin#set_credits'
    post 'ban', to: 'admin#ban'
    post 'unban', to: 'admin#unban'
    post 'activate_maintenance', to: 'admin#activate_maintenance'
    post 'server_message', to: 'admin#server_message'
    post 'mute', to: 'admin#mute'
    post 'unmute', to: 'admin#unmute'
    post 'delete_chat', to: 'admin#delete_chat'
  end
  
  # Polls
  scope :poll do
    post 'create', to: 'polls#create'
    post 'upvote', to: 'polls#upvote'
    post 'downvote', to: 'polls#downvote'
    post 'move_up', to: 'polls#move_up'
    post 'delete', to: 'polls#delete'
  end
  
  # ActionCable
  mount ActionCable.server => '/cable'
  
end
