class Api::V1::SessionsController < ApplicationController
  before_action :authenticate_user!, only: [ :destroy, :show ]
  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      reset_session
      session[:user_id] = user.id
      render json: { message: "ログインしました" }, status: :ok
    else
      render json: { message: "ログインできませんでした" }, status: :unauthorized
    end
  end

  def destroy
    reset_session
    render json: { message: "ログアウトしました" }, status: :ok
  end

  def show
    render json: { current_user: current_user.safe_attributes }, status: :ok
  end
end
