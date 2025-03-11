class CartsController < ApplicationController
  before_action :authenticate_user!

  def index
    @cart_items = current_user.carts.includes(:plant)
  end

  def create
    plant = Plant.find(params[:plant_id])
    cart_item = Cart.find_by(user: current_user, plant: plant)

    if cart_item
      cart_item.quantity += 1
    else
      cart_item = Cart.new(user: current_user, plant: plant, quantity: 1)
    end

    if cart_item.save
      redirect_to carts_path, notice: "Plante ajoutée au panier."
    else
      redirect_to carts_path, alert: "Erreur lors de l'ajout au panier."
    end
  end

  def destroy
    cart_item = Cart.find(params[:id])
    if cart_item.user_id == current_user.id
      cart_item.destroy
      redirect_to carts_path, notice: "Plante retirée du panier."
    else
      redirect_to carts_path, alert: "Action non autorisée."
    end
  end
end
