module Visit
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
        # The http request User-Agent is matched against the regexps in this Array.
        # A Visit::Trait is created if there's a match.
        # Also see Visit::UserAgentRobotQuery.
        # Handy for distinguishing (some) robot traffic from human traffic.

        [
          /Googlebot/i,
          /Twitterbot/i,
          /TweetmemeBot/i,
          /rogerbot/i,
          /YandexBot/i,
          /msnbot/i,
          /bingbot/i,
          /QuerySeekerSpider/i,
          /WormlyBot/i,
          /^Ruby$/i,
          /Pingdom.com_bot/i,
          /InsieveBot/i,
          /undrip/i,
          /EventMachine HttpClient/i,
          /ShowyouBot/i,
          /Python-urllib/i,
          /Kimengi\/nineconnections.com/i,
          /AppEngine-Google/i,
          /PaperLiBot/i
        ]
      end

    end
  end
end
