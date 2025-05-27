Rails.application.routes.draw do
  devise_for :users                          # Move this ABOVE
  resources :users, only: [:show]           # Move this BELOW
  root to: "books#index"

  resources :books, only: [:index, :show] do
    resources :pages, only: [:show], param: :page_number
    resources :favorites, only: [:create]
  end
  resources :favorites, only: [:index, :destroy]
end
