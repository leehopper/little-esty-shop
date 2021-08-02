Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :merchants do
    resources :items, controller: 'merchant_items'
    resources :invoices, controller: 'merchant_invoices'
  end

  resources :invoice_items, only: :update

  # -------Admin routes-------
  namespace :admin do
    resources :merchants
    resources :invoices
  end

  patch '/merchants/:merchant_id/items/:id/status', to: 'merchant_items#update_status', as: 'merchant_item_status'

end
