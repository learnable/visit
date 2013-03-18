Rails.application.routes.draw do

  namespace :visit do; get "/pageviews", to: "pageviews#new", as: :pageviews end

  namespace :visit do; get "/tag.gif",   to: "tag#create",    as: :tag       end

  mount Visit::Engine => "/visit"
end
