Rails.application.routes.draw do

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Hauptseiten mit Zeitraum-Parametern
  root 'leaderboard#index'
  get 'leaderboard/:period', to: 'leaderboard#index', as: 'leaderboard_period',
      constraints: { period: /today|week|all/ }
  
  # Member routes - einfacher aufgebaut
  get 'members/:username', to: 'members#show', as: 'member'
  get 'members/:username/:period', to: 'members#show', as: 'member_period',
      constraints: { period: /today|week|all/ }
  
  # Admin-Bereich
  namespace :admin do
    resources :item_values, only: [:index, :edit, :update]
    post 'sync_now', to: 'sync#create'
  end
  
  get 'health', to: 'application#health'
end