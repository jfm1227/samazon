Rails.application.routes.draw do
  devise_for :admins, controllers: {
    registrations: 'admins/registrations',
    sessions: 'admins/sessions'
  }

  devise_scope :admin do
    get 'dashboard', to: 'dashboard#index'
    get 'dashboard/login', to: 'admins/sessions#new'
    post 'dashboard/login', to: 'admins/sessions#create'
    delete 'dashboard/logout', to: 'admins/sessions#destroy'
  end

  namespace :dashboard do
    resources :major_categories, except: [:new]
    resources :categories, except: [:new]

    resources :products, except: [:show] do
      collection do
        get  'import/csv', to: 'products#import'
        post 'import/csv', to: 'products#import_csv'
        get  'import/csv_download', to: 'products#download_csv'
      end
    end

    resources :orders, only: [:index]
  end

  devise_scope :user do
    root to: 'web#index'
  end

  resource :users, only: %i[edit update] do
    collection do
      get 'cart', to: 'shopping_carts#index'
      post 'cart/create', to: 'shopping_carts#create'
      delete 'cart', to: 'shopping_carts#destroy'
    end
  end

  resource :shopping_carts do
    collection do
      patch :remove_shopping_cart_item
    end
  end

  resources :products
end
