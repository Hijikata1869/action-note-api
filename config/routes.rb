Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resource :user, only: %i[create update destroy]
      resource :session, only: %i[create destroy show]
      resources :books, shallow: true do
        resources :reading_notes, only: %i[create show update destroy]
      end
    end
  end
end
