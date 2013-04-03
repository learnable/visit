module Visit
  class UserAgentRobotQuery
    def initialize(relation = Visit::Event.scoped)
      @relation = relation
    end

    def scoped
      stmt = %Q{
        INNER JOIN visit_traits user_agent_robot_vt
          ON visit_events.id = user_agent_robot_vt.visit_event_id AND user_agent_robot_vt.k_id =
            (select id from visit_trait_values where v = 'robot')
        INNER JOIN visit_trait_values user_agent_robot_vtv
          ON user_agent_robot_vtv.id = user_agent_robot_vt.v_id
      }
      @relation.
        select("visit_events.*, user_agent_robot_vtv.v as user_agent_robot").
        joins(stmt)
    end

  end
end
