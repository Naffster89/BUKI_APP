class UsersController < ApplicationController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)

      redirect_to user_path(@user), notice: "Languages updated!"
    else
      render "users/show", status: :unprocessable_entity
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :birthday, :first_name, :last_name, languages: [])
  end
end
