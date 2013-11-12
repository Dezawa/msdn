class CreateUbeNamedChange < ActiveRecord::Migration
  Columns = [:jun,:pre_condition_id,:post_condition_id,:ope_name,:display
            ].zip(
                  [:integer,:integer,:integer          ,:text ,:text]
                  )
  def self.up
    create_table "ube_named_changes", :force => true do |t|
      Columns.each{|colmn,type| t.send(type , colmn)}
    end
  end

  def self.down
    drop_table "ube_named_changes"
  end
end
