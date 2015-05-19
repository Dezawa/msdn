module GraphController

  def show_img
    graph_format =
      if params[:graph_path]
        params[:graph_path].match(/\.([^.]+)$/)[1]
      else
        params[:graph_format].blank? ?  "jpeg" :  params[:graph_format]
      end        
                                               
    graph_path =
      if params[:graph_path]  ; params[:graph_path]
      else
        graph_file = params[:graph_file].blank? ? "image" : params[:graph_file]
        graph_file_dir = params[:graph_file_dir].blank? ?
          Rails.root+"tmp/graph/jpeg" : params[:graph_file_dir]
        "#{graph_file_dir}/#{ graph_file}.#{graph_format}"
      end
    send_file graph_path, :type => "image/#{graph_format}", :disposition => 'inline'
  end
end
