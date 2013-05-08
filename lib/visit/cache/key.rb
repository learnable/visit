module Visit
  class Cache
    class Key < Struct.new(:part_a, :part_b)
      def key
        "#{part_a}:#{part_b}"
      end
    end
  end
end
