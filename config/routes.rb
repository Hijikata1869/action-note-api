Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :users
      resource :session, only: [ :create, :destroy, :show ]
      resources :books
    end
  end
end
