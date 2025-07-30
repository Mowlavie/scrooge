Rails.application.routes.draw do
  get '/bank/status', to: 'bank#status'
  
  resources :users, only: [:create, :show]
  
  resources :accounts, only: [:create, :show, :destroy] do
    member do
      post :deposit
      post :withdraw
    end
  end
  
  resources :loans, only: [:index, :create] do
    member do
      post :payment
    end
  end
end