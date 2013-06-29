module Visit
  module StoresIpAddress
    extend ActiveSupport::Concern

    included do

      def self.stores_ip_address(attr)
        define_method(attr) do
          require "ipaddr"
          IPAddr.new(read_attribute(attr), Socket::AF_INET).to_s
        end

        define_method(:"#{attr}=") do |ip|
          require "ipaddr"
          write_attribute :remote_ip, (ip.instance_of?(Fixnum) ? ip : IPAddr.new(ip).to_i)
        end
      end
    end
  end
end
