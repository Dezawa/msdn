class CommonController < ApplicationController
  include Actions
  include Permittion
  
  def set_instanse_variable
    @weather_location = session[:weather_location] || "maebashi"
  end
  
  def show_img
    graph_format = params[:graph_format].blank? ? :gif : params[:graph_format]
    graph_path =
      if params[:graph_path] ;params[:graph_path]
      else
        graph_dir  = Rails.root+
          (params[:graph_dir].blank? ? "tmp/img"  :  params[:graph_dir])
        graph_file = graph_dir + (params[:graph_file].blank? ? "power" : params[:graph_file])
        "#{graph_file}.#{graph_format}" 
      end
     send_file graph_path, :type => "#{graph_format}", :disposition => 'inline'
   end
end
