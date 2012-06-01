Server::Application.routes.draw do
  #resources :sources

  root :to      => 'home#index'
  get '/events' => 'events#index'
  post '/events/:id/correct' => 'events#correct', :as => 'correct_event'

  resources :corrections
  resources :trucks

  # See how all your routes lay out with "rake routes"
end
