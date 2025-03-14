Rails.application.routes.draw do
  root "plants#index"

  # Authentification avec Devise
  devise_for :users, controllers: { sessions: 'users/sessions' }

  # Gestion utilisateur (profil personnel)
  resources :users, only: [:show, :edit, :update]

  # Gestion des plantes (publique)
  resources :plants, only: [:index, :show]

  # Gestion du panier
  resources :carts, only: [:index, :create, :destroy]

  # Gestion des commandes
  resources :orders, only: [:index, :new, :create]

  # Administration
  namespace :admin do
    resources :plants, except: [:show]
    resources :users, only: [:index, :edit, :update, :destroy]
  end
end
