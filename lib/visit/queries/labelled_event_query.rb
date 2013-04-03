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

        LEFT OUTER JOIN visit_traits sublabel_vt
          ON visit_events.id = sublabel_vt.visit_event_id AND sublabel_vt.k_id =
            (select id from visit_trait_values where v = 'sublabel')
        LEFT OUTER JOIN visit_trait_values sublabel_vtv
          ON sublabel_vtv.id = sublabel_vt.v_id
      }
      @relation.
        select("visit_events.*, label_vtv.v as label, sublabel_vtv.v as sublabel").
        joins(stmt)
    end

  end
end
