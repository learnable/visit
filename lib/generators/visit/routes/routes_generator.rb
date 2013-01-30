class Visit::RoutesGenerator < Rails::Generators::Base

  def add_route
    route 'get "/visit/tag.gif", to: "visit_tag#create", as: :visit_tag'
  end

end
