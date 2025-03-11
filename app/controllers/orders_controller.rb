class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders
  end

  def new
    @cart_items = current_user.carts.includes(:plant)
  end

  def create
    cart_items = current_user.carts.includes(:plant)
    total = cart_items.sum { |item| item.plant.price * item.quantity }

    @order = Order.new(user: current_user, total_price: total, status: "confirmed")

    if @order.save
      cart_items.each do |item|
        item.plant.update(stock: item.plant.stock - item.quantity)
      end
      current_user.carts.destroy_all
      redirect_to orders_path, notice: "Commande confirmée."
    else
      redirect_to new_order_path, alert: "Erreur lors de la commande."
    end
  end
end
