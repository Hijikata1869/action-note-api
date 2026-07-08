class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!, only: [ :update, :destroy ]
  def create
    user = User.new(user_params)

    if user.save
      login(user)
      render json: { message: "ユーザーを作成しました" }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if current_user.update(user_params)
      render json: { message: "ユーザー情報を更新しました" }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.destroy
    reset_session
    render json: { message: "ユーザーを削除しました" }, status: :ok
  end

  private
  def user_params
    params.require(:user).permit(:nickname, :email, :password, :password_confirmation)
  end
end
