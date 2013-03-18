# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130318050041) do

  create_table "visit_event_archives", :id => false, :force => true do |t|
    t.integer  "id", :default => { :expr => "nextval('visit_events_id_seq'::regclass)" },                            :null => false
    t.integer  "http_method_enum"
    t.integer  "url_id"
    t.integer  "vid",              :limit => 8
    t.integer  "user_id"
    t.integer  "user_agent_id"
    t.integer  "referer_id"
    t.integer  "remote_ip",        :limit => 8
    t.datetime "created_at"
  end

  create_table "visit_events", :force => true do |t|
    t.integer  "http_method_enum"
    t.integer  "url_id"
    t.integer  "vid",              :limit => 8
    t.integer  "user_id"
    t.integer  "user_agent_id"
    t.integer  "referer_id"
    t.integer  "remote_ip",        :limit => 8
    t.datetime "created_at"
    t.index ["vid"], :name => "index_visit_events_on_vid", :order => {"vid" => :asc}
  end

  create_table "visit_source_values", :force => true do |t|
    t.string   "v",          :null => false
    t.datetime "created_at"
    t.index ["v"], :name => "index_visit_source_values_on_v", :unique => true, :order => {"v" => :asc}
  end

  create_table "visit_trait_values", :force => true do |t|
    t.string   "v",          :null => false
    t.datetime "created_at"
    t.index ["v"], :name => "index_visit_trait_values_on_v", :unique => true, :order => {"v" => :asc}
  end

  create_table "visit_traits", :force => true do |t|
    t.integer  "k_id",           :null => false
    t.integer  "v_id",           :null => false
    t.integer  "visit_event_id", :null => false
    t.datetime "created_at"
  end

  create_view "visit_event_views", "SELECT visit_events.id, visit_events.http_method_enum, url_vsv.v AS url, visit_events.user_id, visit_events.vid, label_vtv.v AS label, sublabel_vtv.v AS sublabel, user_agent_vsv.v AS user_agent, visit_events.created_at FROM ((((((visit_events JOIN visit_source_values url_vsv ON ((visit_events.url_id = url_vsv.id))) JOIN visit_source_values user_agent_vsv ON ((visit_events.user_agent_id = user_agent_vsv.id))) LEFT JOIN visit_traits label_vt ON (((visit_events.id = label_vt.visit_event_id) AND (label_vt.k_id = (SELECT visit_trait_values.id FROM visit_trait_values WHERE ((visit_trait_values.v)::text = 'label'::text)))))) LEFT JOIN visit_trait_values label_vtv ON ((label_vtv.id = label_vt.v_id))) LEFT JOIN visit_traits sublabel_vt ON (((visit_events.id = sublabel_vt.visit_event_id) AND (sublabel_vt.k_id = (SELECT visit_trait_values.id FROM visit_trait_values WHERE ((visit_trait_values.v)::text = 'sublabel'::text)))))) LEFT JOIN visit_trait_values sublabel_vtv ON ((sublabel_vtv.id = sublabel_vt.v_id)))", :force => true
  create_table "visit_sources", :force => true do |t|
    t.integer  "k_id",           :null => false
    t.integer  "v_id",           :null => false
    t.integer  "visit_event_id", :null => false
    t.datetime "created_at"
  end

end
