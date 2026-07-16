class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordNotDestroyed, with: :record_not_destroyed

    private
    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def authenticate_user!
      unless current_user
        render json: { message: "ログインしていません" }, status: :unauthorized
      end
    end

    def login(user)
      reset_session
      session[:user_id] = user.id
    end

    def record_not_found
      render json: { message: "Record Not Found" }, status: :not_found
    end

    def record_not_destroyed
      render json: { message: "Record Not Destroyed" }, status: :unprocessable_entity
    end
end
