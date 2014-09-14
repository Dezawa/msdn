# -*- coding: utf-8 -*-
Rails.application.routes.draw do
# The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
 
  def set_get(ctrl,acts)
    acts.each{ |act| get "/#{ctrl}/#{act}" => "#{ctrl}##{act}" }
  end
  def set_post(ctrl,acts)
    acts.each{ |act| post "/#{ctrl}/#{act}" => "#{ctrl}##{act}" }
  end

  EditTable = %w(add_on_table edit_on_table update_on_table csv_out csv_upload csv_download)

  root :to => "top#msdn"
  devise_for :users

  ################## -ユーザ管理
  resources :user_options,:users
  get "/users/sign_in" => "devise/sessions#new"
  %w(user_options users ).
    each{|controller| 
    %w(add_on_table edit_on_table update_on_table csv_out csv_upload).
    each{|action|
      post "#{controller}/#{action}" => "#{controller}##{action}"
    }}
    
  ########### LiPS
  set_get("lips",%w( member calc csv_download))
  set_post("lips",%w(change_form calc)+EditTable)

  
  ########### 天候関連
  resources :weather,:forecast,:weather_location
  set_get(:forecast,%w( fetch error_graph show_img show_gif show_jpeg))
  set_get(:weather,%w( temperatuer humidity show_img))
  set_post(:forecast,%w(change_location))
  set_post(:weather,%w(change_location get_data temp_vaper weather_location cband))
  set_post(:weather_location,%w(change_location)+EditTable)
  
  ########### UBR 
  get  '/ubr/main' =>  'ubr/main#index'
  ubr = %w(main waku waku_block souko_plan souko_floor wall pillar)
  ubr.each{ |ctrl|
    resources "ubr_#{ctrl}" , controller: "ubr/#{ctrl}"
    set_post( "ubr/#{ctrl}",EditTable )
    set_post( "ubr/#{ctrl}",%w(add_assosiation edit_assosiation))
  }
  set_get("ubr/main",%w(occupy_pdf reculc show_pdf ))
  #set_get("ubr/souko_plan",%w(show_plan))
  get "/ubr/souko_plan/show_plan/:id" => "ubr/souko_plan#show_plan"
  get "/ubr/souko_floor/show_floor/:id" => "ubr/souko_floor#show_floor"

  get    '/users/edit' =>            'users#edit'

  ################ 複式簿記
  get    '/book/keeping' => 'book/keeping#index'
  book = %w(main keeping kamoku permission)
  book.each{ |ctrl|
    resources "book_#{ctrl}" , controller: "book/#{ctrl}"
  }
  book.each{ |ctrl|
    controller = "book/#{ctrl}"
    set_post(controller,EditTable+%w(add_assosiation edit_assosiation owner_change_win))
    #
  }
  set_post("book/keeping",%w(year_change))
  set_get("book/keeping",%w(taishaku csv_taishaku motocho book_make help csv_motocho owner_change owner_change_win))
  set_post("book/main",%w(renumber))
  set_get("book/main",%w( book_make  make_new_year csv_out_print sort_by_tytle))
  set_get("book/kamoku",%w(edit_on_table_all_column))

  ############ しまだ
  get "/shimada/factory" => "shimada/factory#index"
  get "/shimada/factory/today/:id" => "shimada/factory#today"
  controller="shimada/factory"
  set_post(controller,EditTable)
  set_get(controller,%w(today update_today clear_today))

  get "/power/ube_hospital/month" => "power/ube_hospital/month#index" 

  ##### Ubeboard
  ubeboard = %w(top skd maintain holyday product operation plan change_times
                 meigara meigara_shortname named_changes  constant )
  get "/ubeboard/top" => "ubeboard/top#top"
  ubeboard.each{ |ctrl|
    resources "ubeboard_#{ctrl}" , controller: "ubeboard/#{ctrl}"
    set_get("ubeboard/#{ctrl}" ,EditTable)
    set_post("ubeboard/#{ctrl}" ,EditTable)
  }
  set_get("ubeboard/top",%w(calc))
  set_get("ubeboard/skd",%w(lips_load))
end

