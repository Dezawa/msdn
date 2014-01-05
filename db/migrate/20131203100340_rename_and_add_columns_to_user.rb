class RenameAndAddColumnsToUser < ActiveRecord::Migration
  def change
    rename_column :users,:login,:username
    add_column    :users,:subdomain,:string
  end
end
