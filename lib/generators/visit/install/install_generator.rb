class Visit::InstallGenerator < Rails::Generators::Base

  def invoke_generators
    %w{ migration }.each do |name|
      generate "visit:#{name}"
    end
  end

end
