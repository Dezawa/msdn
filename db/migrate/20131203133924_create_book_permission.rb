class CreateBookPermission < ActiveRecord::Migration
  def change
    create_table :book_permissions do |t|
    t.string   "login"
    t.string   "owner"
    t.boolean  "show"
    t.boolean  "edit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "permission"
    t.integer  "user_id"
    end
  end
end
