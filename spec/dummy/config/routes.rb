Rails.application.routes.draw do

  devise_for :users

  resources :articles

  root :to => "articles#index"

  namespace :visit do; get "/pageviews", to: "pageviews#new", as: :pageviews end

  namespace :visit do; get "/tag.gif",   to: "tag#create",    as: :tag       end

  mount Visit::Engine => "/visit"
end
