class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]

  def show
    # Bloque l'accès si l'ID ne correspond pas à l'utilisateur actuel
    redirect_to root_path, alert: "Accès interdit." unless @user == current_user
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
    @user = User.find_by(id: params[:id])
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
