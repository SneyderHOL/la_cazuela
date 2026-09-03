Rails.application.routes.draw do
  # Defines the root path route ("/")
  root "pages#home"

  get "about", to: "pages#about", as: :about
  get "contact", to: "pages#contact", as: :contact
  get "location", to: "pages#location", as: :location
  get "menu", to: "pages#menu", as: :menu

  devise_for :users, only: :sessions

  scope module: "admin" do
    authenticate :user, ->(user) { user.admin? } do
      mount_avo
    end
  end

  scope :dashboard do
    get "/", to: "dashboard#index", as: :dashboard
  end

  namespace :dashboard do
    resources :allocations, only: %i[ index show ] do
      member do
        post "free"
        post "clean"
        post "reserve"
      end
      resources :sell_orders, only: :create
    end

    resources :sell_orders, only: %i[ index show ] do
      member do
        post "invoice"
        post "deliver"
        post "close"
        post "payment"
      end
      resources :orders, only: %i[ new create ]
    end

    resources :orders, only: %i[ index show edit update destroy ] do
      member do
        post "confirm"
        post "complete"
      end
    end

    resources :order_products, only: :index, as: :preparations, path: :preparations do
      member do
        post "cook"
        post "complete"
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
