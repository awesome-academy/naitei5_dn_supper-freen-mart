Rails.application.routes.draw do
  get 'sessions/new'
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    get "/signup", to: "users#new"
    post "/users", to: "users#create"
    get "/signin", to: "sessions#new"
    post "/signin", to: "sessions#create"
    delete "/signout", to: "sessions#destroy"
    resources :account_activations, only: :edit
    resources :products, only: :show
    resources :cart, only: %i(index, create)

    namespace :admin do
      root "orders#index"
      resources :orders, only: :index
    end
  end
end
