Rails.application.routes.draw do
  get 'home/index'

  root 'home#index'
  resources :home

  mount Crono::Web, at: '/crono'
end
