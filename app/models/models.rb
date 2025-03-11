class Cart < ApplicationRecord
  belongs_to :user
  belongs_to :plant
end
class Order < ApplicationRecord
  belongs_to :user
end
class Plant < ApplicationRecord
end
# app/models/user.rb
class User < ApplicationRecord
  # Devise : modules d'authentification
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable
         # On n’active PAS :recoverable, :confirmable, :trackable, etc.

  # Ajout d'un champ admin (si vous en avez un)
  def admin?
    self.admin # Suppose que vous avez un champ "admin" (boolean) dans la table users
  end
end
