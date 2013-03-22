module Visit
  # This class is designed to be opened and overriden by the parent app.
  class Configurable
    class << self

      # Parent app should override this to return an array of label-matchers,
      # where each label-matcher is a hash with keys
      # :http_method, :re, :label, :has_sublabel
      # For example, for an 'alpha_signups' label:
      # {
      #   :http_method  => :post,
      #   :re           => /^\/alpha_signups/,
      #   :label        => :alpha_signups,
      #   :has_sublabel => false
      # }
      def labels
        raise_exception_delegator
      end

      # Parent app should override this to return an array of ruby reg-exps,
      # specifing a black-list of paths to be ignored, for example,
      # to ignore requests to the /api/* path:
      # /^\/api/
      def ignorable
        raise_exception_delegator
      end

      private

      def raise_exception_delegator
        begin
          raise RuntimeError, "Visit::Configurable - expected a configurable method to be overridden by config/initializers"
        rescue => e
          catch_exception_delegate(e)
        end
      end

      def catch_exception_delegate(e)
        raise e
      end

    end
  end
end
