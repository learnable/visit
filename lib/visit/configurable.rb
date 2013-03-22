module Visit
  # This class is designed to be opened and overriden by the parent app.
  class Configurable
    class << self

      # Parent app should override this to return an array of label-matchers,
      # where each label-matcher has format
      # [ :http_method, /path_reg_exp/, :label_name, has_sublabel_bool]
      # For example, for an 'alpha_signups' label:
      # [ :post, /^\/alpha_signups/, :alpha_signups, false ]
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
