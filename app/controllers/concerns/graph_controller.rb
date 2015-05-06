module GraphController

  def show_img
    graph_file = params[:graph_file].blank? ? "image" : params[:graph_file]
    graph_file_dir = params[:graph_file_dir].blank? ?
                  Rails.root+"tmp/graph/jpeg" : params[:graph_file_dir]
    graph_format = params[:graph_format].blank? ?  "jpeg" :  params[:graph_format]
    send_file "#{graph_file_dir}/#{ graph_file}.#{graph_format}",
    :type => "image/#{graph_format}", :disposition => 'inline'
  end
end
