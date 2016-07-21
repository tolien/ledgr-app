Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root :to => 'static#index'

  devise_for :users
  resources :autocomplete, :only => [:index]

  resources :users, :path => "", :only => [:show] do
    resources :categories, :items, :entries
    resources :pages, except: :index
    resources :displays, only: [:show, :create, :edit, :update, :destroy]
    resource :quick_entries, :only => [:create]
  end

end
