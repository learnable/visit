class Visit::RoutesGenerator < Rails::Generators::Base

  def add_route
    route 'namespace :visit do; get "/tag.gif", to: "tag#create", as: :visit_tag end'
  end

end
