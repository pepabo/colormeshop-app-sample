Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'top#show'
  put '/', to: 'top#update'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/js/disable-right-click.js', to: 'js#show', format: :js
end
