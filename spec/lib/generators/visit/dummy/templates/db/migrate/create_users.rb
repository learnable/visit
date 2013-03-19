class CreateUsers < ActiveRecord::Migration
  create_table :users, :force => true do |t|
    t.string  :login
  end

end
