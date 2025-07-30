class UsersController < ApplicationController
  def create
    user = User.create!(user_params)
    render json: user, status: :created
  end
  
  def show
    user = User.find(params[:id])
    render json: {
      id: user.id,
      name: user.name,
      email: user.email,
      account: user.active_account,
      loans: user.loans.active
    }
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email)
  end
end