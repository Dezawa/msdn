class CreateUserOption < ActiveRecord::Migration
  def change
    create_table :user_options do |t|
    t.text     "label"
    t.text     "url"
    t.integer  "order"
    t.text     "comment"
    t.text     "authorized"
    end
  end
end
