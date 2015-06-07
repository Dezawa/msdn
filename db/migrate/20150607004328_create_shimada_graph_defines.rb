class CreateShimadaGraphDefines < ActiveRecord::Migration
  def change
    create_table :shimada_graph_defines do |t|
      t.integer :factory_id
      t.string  :name
      t.string  :title
      t.string  :graph_type
      t.text    :serials
    end
  end
end
