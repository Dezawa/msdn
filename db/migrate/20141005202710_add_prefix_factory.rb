class AddPrefixFactory < ActiveRecord::Migration
  def change
    add_column :shimada_factories,:prefix,:text
  end
end
