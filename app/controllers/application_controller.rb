class ApplicationController < ActionController::API
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
end
