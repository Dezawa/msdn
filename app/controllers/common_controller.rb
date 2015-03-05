class CommonController < ApplicationController
  include Actions
  include Permittion
  
   def show_img
     graph_dir  = Rails.root+
       (params[:graph_dir].blank? ? "tmp/img"  :  params[:graph_dir])
     graph_file = graph_dir + (params[:graph_file].blank? ? "power" : params[:graph_file])
     graph_format = params[:graph_format].blank? ? :gif : params[:graph_format]
     send_file "#{graph_file}.#{graph_format}", :type => "#{graph_format}", :disposition => 'inline'
   end
end
