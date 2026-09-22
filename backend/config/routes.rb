Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :employees, only: [:index, :show] do
        member do
          post :adjust_salary
        end
        collection do
          get :export
        end
      end

      namespace :analytics do
        get :summary
        get :department_breakdown
        get :location_breakdown
        get :pay_equity
        get :compa_distribution
        get :outliers
      end

      get "reference_data", to: "reference_data#index"
    end
  end
end
