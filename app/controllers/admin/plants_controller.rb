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
