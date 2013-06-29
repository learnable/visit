module Visit
  class InstallGenerator < Rails::Generators::Base
    def invoke_generators
      %w{ migration routes }.each do |name|
        generate "visit:#{name}"
      end
    end
  end
end
