Rails.application.routes.draw do
  devise_for :users
  resources :users,only: [:show,:index,:edit,:update] do
  	resource :relationships, only: [:create, :destroy]
  end
  resources :books do
  	resource :favorites, only: [:create, :destroy]
  	resources :book_comments, only:[:create, :destroy]
  end
  root 'home#top'
  get 'home/about'
  get 'users/:id/follower_index' => 'users#follower_index', as: 'follower'
  get 'users/:id/followed_index' => 'users#followed_index', as: 'followed'
end