class Api::V1::SessionsController < ApplicationController
  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
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
end
