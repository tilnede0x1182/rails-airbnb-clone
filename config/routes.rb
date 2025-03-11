Rails.application.routes.draw do
  root "plants#index"

  # Authentification avec Devise (si utilisé)
  devise_for :users

  # Gestion des plantes (publique)
  resources :plants, only: [:index, :show]

  # Gestion du panier
  resources :carts, only: [:index, :create, :destroy]

  # Gestion des commandes
  resources :orders, only: [:index, :new, :create]

  # Gestion utilisateur (profil personnel)
  resources :users, only: [:show, :edit, :update]

  # Administration
  namespace :admin do
    resources :plants, except: [:show]
    resources :users, only: [:index, :edit, :update, :destroy]
  end
end
