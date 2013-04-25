module Visit
  class LabelledEventQuery
    def initialize(relation = Visit::Event.scoped)
      @relation = relation
    end

    def scoped
      stmt = %Q{
        INNER JOIN visit_traits label_vt
          ON visit_events.id = label_vt.visit_event_id AND label_vt.k_id =
            (select id from visit_trait_values where v = 'label')
        INNER JOIN visit_trait_values label_vtv
          ON label_vtv.id = label_vt.v_id

        LEFT OUTER JOIN visit_traits capture1_vt
          ON visit_events.id = capture1_vt.visit_event_id AND capture1_vt.k_id =
            (select id from visit_trait_values where v = 'capture1')
        LEFT OUTER JOIN visit_trait_values capture1_vtv
          ON capture1_vtv.id = capture1_vt.v_id

        LEFT OUTER JOIN visit_traits capture2_vt
          ON visit_events.id = capture2_vt.visit_event_id AND capture2_vt.k_id =
            (select id from visit_trait_values where v = 'capture2')
        LEFT OUTER JOIN visit_trait_values capture2_vtv
          ON capture2_vtv.id = capture2_vt.v_id
      }
      @relation.
        select("visit_events.*, label_vtv.v as label, capture1_vtv.v as capture1, capture2_vtv.v as capture2").
        joins(stmt)
    end

  end
end
