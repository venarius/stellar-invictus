Rails.application.routes.draw do
  devise_for :users, path: '', path_names: { sign_in: 'connect', sign_out: 'disconnect', sign_up: 'enlist'}
  
  root 'static_pages#home'
  
  get '/about', to: 'static_pages#about'
  get '/credits', to: 'static_pages#credits'
  
  resources :factions, only: [:index]
  scope :faction do
    post 'choose', to: 'factions#choose_faction', as: :choose_faction
  end
  
end
