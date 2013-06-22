require 'activerecord-import'

# ActiveSupport dependencies.

%w{
  concern
  inflector
  core_ext/hash/reverse_merge
  core_ext/object/blank
}.each { |name| require "active_support/#{name}" }

Dir[File.join(File.dirname(__FILE__), 'visit', '*.rb')].each do |file|
  require file unless (file =~ /engine/)
end

%w( cache factory flow instrumenter query serialized_queue ).each do |subdir|
  Dir[File.join(File.dirname(__FILE__), 'visit', subdir, '*.rb')].each do |file|
    require file
  end
end

require "visit/engine" if defined?(Rails)
