class PlantsController < ApplicationController
  def index
    @plants = Plant.all
  end

  def show
    @plant = Plant.find(params[:id])
  end
end
module Admin
  class PlantsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def index
      @plants = Plant.all
    end

    def new
      @plant = Plant.new
    end

    def create
      @plant = Plant.new(plant_params)
      if @plant.save
        redirect_to admin_plants_path, notice: "Plante créée."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @plant = Plant.find(params[:id])
    end

    def update
      @plant = Plant.find(params[:id])
      if @plant.update(plant_params)
        redirect_to admin_plants_path, notice: "Plante mise à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @plant = Plant.find(params[:id])
      @plant.destroy
      redirect_to admin_plants_path, notice: "Plante supprimée."
    end

    private

    def plant_params
      params.require(:plant).permit(:name, :price, :description, :stock)
    end

    def require_admin
      unless current_user.admin?
        redirect_to root_path, alert: "Accès interdit."
      end
    end
  end
end
module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def index
      @users = User.all
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Utilisateur mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])
      @user.destroy
      redirect_to admin_users_path, notice: "Utilisateur supprimé."
    end

    private

    def user_params
      params.require(:user).permit(:email, :name, :admin)
    end

    def require_admin
      unless current_user.admin?
        redirect_to root_path, alert: "Accès interdit."
      end
    end
  end
end
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
      redirect_to plants_path, alert: "Erreur lors de l'ajout au panier."
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
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Profil mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
    if @user != current_user
      redirect_to root_path, alert: "Accès interdit."
    end
  end

  def user_params
    # Ajustez les champs selon votre modèle
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end
end
module Admin
  class PlantsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def create
      @plant = Plant.new(plant_params)
      if @plant.save
        redirect_to plants_path, notice: "Nouvelle plante créée avec succès."
      else
        flash[:alert] = "Erreur lors de la création de la plante."
        render :new, status: :unprocessable_entity
      end
    end

    # etc. (edit, update, destroy)

    private

    def plant_params
      params.require(:plant).permit(:name, :price, :description, :stock)
    end

    def require_admin
      unless current_user.admin?
        redirect_to root_path, alert: "Accès interdit. Seuls les administrateurs peuvent effectuer cette action."
      end
    end
  end
end
class ApplicationController < ActionController::Base
end
# app/controllers/carts_controller.rb
class CartsController < ApplicationController
  before_action :authenticate_user!

  def create
    # Récupère la plante à ajouter
    plant = Plant.find(params[:plant_id])

    # Cherche s'il existe déjà un item pour cette plante
    cart_item = Cart.find_by(user: current_user, plant: plant)
    if cart_item
      cart_item.quantity += 1
    else
      cart_item = Cart.new(user: current_user, plant: plant, quantity: 1)
    end

    if cart_item.save
      redirect_to plants_path, notice: "Plante ajoutée au panier."
    else
      redirect_to plants_path, alert: "Impossible d'ajouter la plante."
    end
  end

  def destroy
    cart_item = Cart.find(params[:id])
    if cart_item.user_id == current_user.id
      cart_item.destroy
      redirect_to plants_path, notice: "Plante retirée du panier."
    else
      redirect_to plants_path, alert: "Action non autorisée."
    end
  end
end
# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  before_action :authenticate_user!

  def new
    # Page de validation de commande (checkout)
    @cart_items = current_user.carts.includes(:plant)
  end

  def create
    # Création d'une commande
    cart_items = current_user.carts.includes(:plant)
    total = 0
    cart_items.each do |item|
      total += item.plant.price * item.quantity
    end

    @order = Order.new(user: current_user, total_price: total, status: "confirmed")
    if @order.save
      # Mettre à jour le stock
      cart_items.each do |item|
        new_stock = item.plant.stock - item.quantity
        item.plant.update(stock: new_stock)
      end
      # Vider le panier
      current_user.carts.destroy_all

      redirect_to orders_path, notice: "Commande confirmée."
    else
      redirect_to new_order_path, alert: "Erreur lors de la commande."
    end
  end

  def index
    # Liste de toutes les commandes de l'utilisateur
    @orders = Order.where(user: current_user)
  end
end
class PlantsController < ApplicationController
  def index
    @plants = Plant.all
  end

  def show
    @plant = Plant.find(params[:id])
  end
end
class ApplicationController < ActionController::Base
end
class PlantsController < ApplicationController
  def index
    @plants = Plant.all
  end

  def show
    @plant = Plant.find(params[:id])
  end
end
module Admin
  class PlantsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def index
      @plants = Plant.all
    end

    def new
      @plant = Plant.new
    end

    def create
      @plant = Plant.new(plant_params)
      if @plant.save
        redirect_to admin_plants_path, notice: "Plante créée."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @plant = Plant.find(params[:id])
    end

    def update
      @plant = Plant.find(params[:id])
      if @plant.update(plant_params)
        redirect_to admin_plants_path, notice: "Plante mise à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @plant = Plant.find(params[:id])
      @plant.destroy
      redirect_to admin_plants_path, notice: "Plante supprimée."
    end

    private

    def plant_params
      params.require(:plant).permit(:name, :price, :description, :stock)
    end

    def require_admin
      unless current_user.admin?
        redirect_to root_path, alert: "Accès interdit."
      end
    end
  end
end
module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def index
      @users = User.all
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Utilisateur mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])
      @user.destroy
      redirect_to admin_users_path, notice: "Utilisateur supprimé."
    end

    private

    def user_params
      params.require(:user).permit(:email, :name, :admin)
    end

    def require_admin
      unless current_user.admin?
        redirect_to root_path, alert: "Accès interdit."
      end
    end
  end
end
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
      redirect_to plants_path, alert: "Erreur lors de l'ajout au panier."
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
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Profil mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
    if @user != current_user
      redirect_to root_path, alert: "Accès interdit."
    end
  end

  def user_params
    # Ajustez les champs selon votre modèle
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end
end
module Admin
  class PlantsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def create
      @plant = Plant.new(plant_params)
      if @plant.save
        redirect_to plants_path, notice: "Nouvelle plante créée avec succès."
      else
        flash[:alert] = "Erreur lors de la création de la plante."
        render :new, status: :unprocessable_entity
      end
    end

    # etc. (edit, update, destroy)

    private

    def plant_params
      params.require(:plant).permit(:name, :price, :description, :stock)
    end

    def require_admin
      unless current_user.admin?
        redirect_to root_path, alert: "Accès interdit. Seuls les administrateurs peuvent effectuer cette action."
      end
    end
  end
end
class ApplicationController < ActionController::Base
end
# app/controllers/carts_controller.rb
class CartsController < ApplicationController
  before_action :authenticate_user!

  def create
    # Récupère la plante à ajouter
    plant = Plant.find(params[:plant_id])

    # Cherche s'il existe déjà un item pour cette plante
    cart_item = Cart.find_by(user: current_user, plant: plant)
    if cart_item
      cart_item.quantity += 1
    else
      cart_item = Cart.new(user: current_user, plant: plant, quantity: 1)
    end

    if cart_item.save
      redirect_to plants_path, notice: "Plante ajoutée au panier."
    else
      redirect_to plants_path, alert: "Impossible d'ajouter la plante."
    end
  end

  def destroy
    cart_item = Cart.find(params[:id])
    if cart_item.user_id == current_user.id
      cart_item.destroy
      redirect_to plants_path, notice: "Plante retirée du panier."
    else
      redirect_to plants_path, alert: "Action non autorisée."
    end
  end
end
# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  before_action :authenticate_user!

  def new
    # Page de validation de commande (checkout)
    @cart_items = current_user.carts.includes(:plant)
  end

  def create
    # Création d'une commande
    cart_items = current_user.carts.includes(:plant)
    total = 0
    cart_items.each do |item|
      total += item.plant.price * item.quantity
    end

    @order = Order.new(user: current_user, total_price: total, status: "confirmed")
    if @order.save
      # Mettre à jour le stock
      cart_items.each do |item|
        new_stock = item.plant.stock - item.quantity
        item.plant.update(stock: new_stock)
      end
      # Vider le panier
      current_user.carts.destroy_all

      redirect_to orders_path, notice: "Commande confirmée."
    else
      redirect_to new_order_path, alert: "Erreur lors de la commande."
    end
  end

  def index
    # Liste de toutes les commandes de l'utilisateur
    @orders = Order.where(user: current_user)
  end
end
class PlantsController < ApplicationController
  def index
    @plants = Plant.all
  end

  def show
    @plant = Plant.find(params[:id])
  end
end
class ApplicationController < ActionController::Base
end
