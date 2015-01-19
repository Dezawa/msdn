# -*- coding: utf-8 -*-
class TodosController < CommonController # ApplicationController
  #before_action :set_todo, only: [:show, :edit, :update, :destroy]
  before_action :set_instanse_variable
  
  Labels = [
      HtmlNum.new(:id,"番号", ro: true),
      HtmlSelect.new(  :status  ,"状態",:correction =>  %w(未着手 着手 保留 却下 完了), ),
      HtmlText.new( :task    ,"アプリ",size: 5 ),
      HtmlText.new( :title   ,"問題タイトル",size: 15  ),
      HtmlText.new( :branch  ,"Branch名" ,size: 5 ),
      HtmlText.new( :tag     ,"TAG名"  ,size: 5),
      HtmlArea.new( :note    ,"Todo・症状" ),
      HtmlArea.new( :measures,"対処" ),
            ] 
  def set_instanse_variable
    @Model= Todo
    @Domain= @Model.name.underscore
    @labels = Labels
    @TYTLE = "Todo"
    @TableEdit = true
    @Show = @Edit = @Delete=true
    @FindOrder("id decs")
    @Pagenation = 20
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def todo_params
      params[:todo]
    end
end
