module Visit
  # This class is designed to be opened and overriden by the parent app.
  class Configurable
    class << self

      def labels

        # The app should override this method and return an array whose elements are ultimately
        # passed to the Visit::Event::Matcher constructor.
        # eg:
        # [
        #   [ :post, /^\/contact\/deliver/,       :contact_deliver,       false ],
        #   [ :get,  /^\/contact/,                :contact_prompt,        false ],
        #   [ :get,  /^\/login?.*intended=(.*)$/, :login_prompt,          true  ],
        #   [ :any,  /^\/assessment\/url\/(.*)/,  :url_assessment,        true  ]
        # ]

        raise_exception_delegator
      end

      def user_agent_robots
        [
          "Googlebot",
          "Twitterbot",
          "TweetmemeBot",
          "rogerbot",
          "YandexBot",
          "msnbot",
          "bingbot",
          "QuerySeekerSpider",
          "WormlyBot",
          "Ruby",
          "Pingdom.com_bot",
          "InsieveBot",
          "undrip",
          "EventMachine HttpClient",
          "ShowyouBot",
          "Python-urllib",
          "Kimengi/nineconnections.com",
          "AppEngine-Google",
          "PaperLiBot"
        ]
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
