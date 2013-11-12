class CreateMeigaraShortname < ActiveRecord::Migration
  Columns = [:name,:short_name,:ube_meigara_id].zip(
                                        [:text,:text,:integer]
                                        )
  Table = :ube_meigara_shortnames
  def self.up
    create_table Table, :force => true do |t|
      Columns.each{|colmn,type| t.send(type , colmn)}
    end
  end

  def self.down
    drop_table Table
  end
end
