module Visit
  class Cache
    class Key < Struct.new(:part_a, :part_b)
      def initialize(a,b)
        self[:part_a] = case_convert a.to_s
        self[:part_b] = case_convert b.to_s

        self[:part_a].freeze
        self[:part_b].freeze
      end

      def key
        @key ||= "#{part_a}:#{part_b}" # this gets called a lot - optimise for speed
      end
      alias_method :to_s, :key

      private

      def case_convert(str)
        Configurable.case_insensitive_string_comparison ? str.downcase : str
      end
    end
  end
end
