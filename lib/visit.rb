# ActiveSupport dependencies.
%w{
  concern
  inflector
  core_ext/hash/reverse_merge
  core_ext/object/blank
}.each { |name| require "active_support/#{name}" }

Dir[File.join(File.dirname(__FILE__), 'visit', '*.rb')].each do |file|
  if !(file =~ /engine/)
    # puts "AMHERE: lib/visit.rb: requiring: #{file}"
    require file
  end
end

require "visit/engine" if defined?(Rails)

module Visit
  # unloadable if defined?(Rails) && Rails.env.development?
end
