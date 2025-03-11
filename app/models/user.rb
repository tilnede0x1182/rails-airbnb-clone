# app/models/user.rb
class User < ApplicationRecord
  # Devise : modules d'authentification
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable
         # On n’active PAS :recoverable, :confirmable, :trackable, etc.

  # Associations manquantes
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy

  # Ajout d'un champ admin (si vous en avez un)
  def admin?
    self.admin # Suppose que vous avez un champ "admin" (boolean) dans la table users
  end
end
