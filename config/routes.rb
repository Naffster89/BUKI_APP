Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:show]

  root to: "books#index"

  resources :books, only: [:index, :show, :update] do
    resources :pages, only: [:show], param: :page_number
    resources :favorites, only: [:create]
  end

  resources :favorites, only: [:index, :destroy]
end

