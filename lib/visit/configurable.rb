module Visit
  # This class is designed to be opened and overriden by the parent app.
  class Configurable
    class << self

      def labels
        # The app can override this method to identify requests that are of specific interest.
        #
        # The elements of this array are passed to the Visit::Event::Matcher constructor.
        # eg:
        # [
        #   [ :post, /^\/contact\/deliver/,       :contact_deliver,       false ],
        #   [ :get,  /^\/contact/,                :contact_prompt,        false ],
        #   [ :get,  /^\/login?.*intended=(.*)$/, :login_prompt,          true  ],
        #   [ :any,  /^\/assessment\/url\/(.*)/,  :url_assessment,        true  ]
        # ]
      end

      def ignorable
        # Before storing an event, the gem matches the http request path against the regexps returned by this method.
        # If there's a match, the request is ignored.
        # Helps avoid filling up the database with requests to polling endpoints.
        #
        # [
        #   /^\/api/
        # ]
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
