module Visit
  class RoutesGenerator < Rails::Generators::Base

    def add_route
      route 'namespace :visit do; get "/tag.gif",   to: "tag#create",    as: :tag       end'
      route 'namespace :visit do; get "/pageviews", to: "pageviews#new", as: :pageviews end'
    end

  end
end
