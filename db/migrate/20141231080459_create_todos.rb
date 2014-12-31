class CreateTodos < ActiveRecord::Migration
  def change
    create_table :todos do |t|
      t.string  :status
      t.string  :task
      t.string  :title
      t.string  :branch
      t.string  :tag
      t.text    :note
      t.text    :measures
      t.timestamps
    end
  end
end
