Rails.application.routes.draw do
  # Devise Routes für User-Authentication
  devise_for :users
  
  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Hauptseiten
  root 'leaderboard#index'
  get 'leaderboard/:period', to: 'leaderboard#index', as: 'leaderboard_period',
      constraints: { period: /today|week|all/ }
  
  # Member routes
  get 'members/:username', to: 'members#show', as: 'member'
  get 'members/:username/:period', to: 'members#show', as: 'member_period',
      constraints: { period: /today|week|all/ }
  
  # Admin-Donation-Toggle
  patch 'donations/:donation_id/toggle_excluded', to: 'members#toggle_donation_excluded', as: 'toggle_donation_excluded'
  
  # Admin-Bereich
  namespace :admin do
    resources :item_values, only: [:index, :edit, :update]
  end

  if Rails.env.development?
    get '/debug/champions', to: 'debug#champions'
  end
end