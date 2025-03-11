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
