class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]

  def edit
    @user = User.find(params[:id])
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Profil mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy

  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :description, :profile_picture) # Ajoute d'autres champs si nécessaire
  end
end
