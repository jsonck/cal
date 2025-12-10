require 'sidekiq/web'

# Manually load Grape API files (outside of Zeitwerk autoloading)
Dir[Rails.root.join('app/api/**/*.rb')].sort.each do |file|
  load file
end

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root path
  root "home#index"

  # Static pages
  get '/terms', to: 'pages#terms'
  get '/privacy', to: 'pages#privacy'
  get '/support', to: 'pages#support'

  # OAuth routes
  get '/auth/:provider/callback', to: 'sessions#create'
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  delete '/logout', to: 'sessions#destroy'

  # Settings routes
  get '/settings', to: 'settings#show'
  patch '/settings', to: 'settings#update'

  # Event reminders routes
  resources :events, only: [] do
    resources :reminders, controller: 'event_reminders', only: [:index, :create, :destroy]
  end

  # Webhook routes
  post '/webhooks/google_calendar', to: 'webhooks#google_calendar'

  # Sidekiq Web UI
  # In production, protect this with authentication:
  # authenticate :user, ->(user) { user.admin? } do
  #   mount Sidekiq::Web => '/sidekiq'
  # end
  mount Sidekiq::Web => '/sidekiq'

  # Mount Grape API
  mount API => '/'
end
