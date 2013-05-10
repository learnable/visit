module Visit
  class Query
    class CpcCampaign < Query
      def scoped
        super.
          where("utm_medium_vtv.v = 'cpc'")
      end

      protected

      def stmt
        stmt_join_trait("INNER JOIN",      'utm_medium') +
        stmt_join_trait("LEFT OUTER JOIN", 'utm_campaign')
      end
    end
  end
end
