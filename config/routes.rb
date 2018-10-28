Rails.application.routes.draw do
  devise_for :users, path: '', path_names: { sign_in: 'connect', sign_out: 'disconnect', sign_up: 'enlist', edit: 'pilot' }
  
  root 'static_pages#home'
  
  get '/about', to: 'static_pages#about'
  get '/credits', to: 'static_pages#credits'
  get '/nojs', to: 'static_pages#nojs'
  
  resources :factions, only: [:index]
  scope :factions do
    post 'choose', to: 'factions#choose_faction', as: :choose_faction
  end
  
  get '/game', to: 'game#index'
  post '/game/warp', to: 'game#warp'
  post '/game/jump', to: 'game#jump'
  get 'game/local_players', to: 'game#local_players'
  
  get '/user/info/:id', to: 'users#info'
  
  mount ActionCable.server => '/cable'
  
end
