Server::Application.routes.draw do
  root :to      => 'home#index'
  get '/events' => 'events#index'
  post '/events/:id/correct' => 'events#correct', :as => 'correct_event'

  resources :corrections

  constraints :ip => /127.0.0.1/ do
    resources :events
  end

  # See how all your routes lay out with "rake routes"
end
