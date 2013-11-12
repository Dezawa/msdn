class CreateUbeConstant < ActiveRecord::Migration
  Columns = [:name,:value,:comment].zip(
                                        [:text,:integer,:text]
                                        )
  def self.up
    create_table "ube_constants", :force => true do |t|
      #t.name
      Columns.each{|colmn,type| t.send(type , colmn)}
    end
  end

  def self.down
    drop_table "ube_constants"
  end
end
