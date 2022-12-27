# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end

  namespace :api do
    resources :users, path: '', only: [:show] do
      resources :displays
    end
  end

  root to: 'static#index'

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  resources :autocomplete, only: [:index]

  resources :users, path: '', only: [:show] do
    resources :categories, :items, :entries
    resources :pages, except: :index
    resources :displays, only: %i[show create edit update destroy]
    resource :quick_entries, only: [:create]

    member do
      get 'settings'
      get 'export_data'
      post 'revoke_oauth_token'
    end
  end
end
