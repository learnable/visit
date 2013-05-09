module Visit
  class Query::UserAgentRobot < Query
    protected

    def stmt
      stmt_join_trait("INNER JOIN", 'robot')
    end

  end
end
