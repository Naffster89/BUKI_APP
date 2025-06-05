Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:show, :update]

  root to: "books#index"

  resources :books, only: [:index, :show, :update, :new, :create] do
    resources :pages, only: [:show], param: :page_number
    resources :favorites, only: [:create]
  end
  resources :pages, only: [] do
    resource :recordings, only: [:create]
  end

  resources :favorites, only: [:index, :destroy]

  get "/tts", to: "tts#speak"
  post "tts/speak", to: "tts#speak"
  post "tts/voicevox", to: "tts#voicevox"
end
