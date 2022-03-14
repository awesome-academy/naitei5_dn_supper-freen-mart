class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      @user.send_activated_email
      flash[:info] = t ".success_message"
      redirect_to root_url
    else
      flash.now[:danger] = t ".failure_message"
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email,
                                 :password, :password_confirmation)
  end
end
