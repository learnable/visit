module Visit
  class Query::JoinWithTokensForUser < Query
    def initialize(user_id, relation = Event.scoped)
      @user_id = user_id
      @relation = relation
    end

    def scoped
      super.
        joins(%Q{
        INNER JOIN
          (SELECT DISTINCT token FROM visit_events WHERE user_id = '#{@user_id}') visit_user_tokens
          ON visit_user_tokens.token = visit_events.token
      })
    end
  end
end
