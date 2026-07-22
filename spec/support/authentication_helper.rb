module AuthenticationHelper
  def login_as(user, password: "password123")
    post "/api/v1/session", params: { email: user.email, password: password }
  end
end
