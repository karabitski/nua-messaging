Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  root :to => 'messages#index'

  resources :messages, only: [:new, :show, :create, :index]
  get  '/messages/outbox', to: 'messages#outbox'
  post '/messages/paid',   to: 'messages#paid'
end
