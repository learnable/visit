module Visit
  class Cache
    class Key
      def initialize(a,b)
        @key ||= case_convert "#{a.to_s}:#{b.to_s}"
      end

      attr_reader :key
      alias_method :to_s, :key

      private

      def case_convert(str)
        Configurable.case_insensitive_string_comparison ? str.downcase : str
      end
    end
  end
end
