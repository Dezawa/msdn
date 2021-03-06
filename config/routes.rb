# -*- coding: utf-8 -*-
Rails.application.routes.draw do

  namespace :test_case do
    resources :test
  end
  
  namespace :sola do
    resources :instruments
  end

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
 
  def set_get(model,acts)
    acts.each{ |act| get "/#{model}/#{act}" => "#{model}##{act}" }
  end
  def set_post(model,acts)
    acts.each{ |act| post "/#{model}/#{act}" => "#{model}##{act}" }
  end
  def set_resources(module_name,model)
    resources "#{module_name}_#{model}".gsub(/\//,"_"),
    #resources "#{module_name}_#{model}",
    path: "#{module_name}/#{model}", 
    controller: "#{module_name}/#{model}"
  end

  def edit_table(*args)
    args.each{|model|
      set_get(model,%w(add_on_table edit_on_table csv_out csv_download))
      set_post(model,%w( update_on_table  csv_upload))
    }
  end
  @EditTable = %w(add_on_table edit_on_table update_on_table csv_out csv_upload csv_download)
 
  root :to => "top#msdn"
  devise_for :users

  ################## -ユーザ管理
   edit_table :user_options,:users
  resources :user_options,:users
  get "/users/sign_in" => "devise/sessions#new"
  post "/users/sign_up" => "users#create"
  %w(user_options users ).each{|controller| set_post(controller,@EditTable)    }
    
  # ########### LiPS
  # set_get("lips",%w( member calc csv_download))
  # set_post("lips",%w(change_form calc)+@EditTable)
  # get "/lips" => "lips#member" 

  # ########### Todo
  # set_post("todos",@EditTable)
  # resources :todos

  ########### 太陽光発電
  set_post( "sola/dayly",@EditTable )
  set_post( "sola/dayly",%w(load) )
  set_get("sola/dayly",%w( index_day_total index_volt show_volt index_monitor index_month load_local_file show show_img
                           show_graph peak_graph minute_graph correlation))

    set_get("sola/dayly",@EditTable)

  get "sola" => "sola/monthly#index"
  namespace :sola do
    get "dayly/index_month" => "dayly#index_month"
    resources :monthly, :dayly
  end
  ########### 状態管理：おんどとり
  set_get("status/tand_d",%w(load_local_file list))
  namespace :status do
    resources :tand_d
  end
  
  ########### 天候関連
  set_get(:forecast,%w( fetch graph error_graph show_img show_gif show_jpeg))
  set_get(:weather,%w( temperatuer humidity show_img plot_year))
  set_post(:forecast,%w(change_location))
  set_post(:weather,%w(change_location get_data temp_vaper weather_location cband))
  set_post(:weather_location,%w(change_location))
  edit_table :weather_location
  resources :weather,:forecast,:weather_location
  
  # ########### UBR 
  # ubr = %w(main waku waku_block souko_plan souko_floor wall pillar)
  # set_get("ubr/main",%w(occupy_pdf reculc show_pdf ))
  # get "/ubr/souko_plan/show_plan/:id" => "ubr/souko_plan#show_plan"
  # get "/ubr/souko_floor/show_floor/:id" => "ubr/souko_floor#show_floor"

  # ubr.each{ |model|
  #   set_resources("ubr",model) 
  #   set_post( "ubr/#{model}",@EditTable )
  #   set_post( "ubr/#{model}",%w(add_assosiation edit_assosiation))
  # }

  # ######
  # ########## 複式簿記
  # set_get("book/main",%w( book_make  make_new_year csv_out_print sort_by_tytle sort))
  # set_post("book/main",%w(  make_new_year change_per_page))
  # book = %w(main kamoku permission)
  # book.each{ |model|
  #   set_post("book/#{model}",@EditTable)
  #   set_get("book/#{model}",@EditTable)
  #   set_resources("book",model) 
  #   set_post("book/#{model}",%w(add_assosiation edit_assosiation owner_change_win owner_change))
  # }
  # get "/book/keeping" => "book/keeping#index"
  # set_post("book/keeping",%w())
  # set_get("book/keeping",%w(taishaku csv_taishaku motocho book_make help csv_motocho owner_change owner_change_win year_change))
  # set_post("book/main",%w(renumber))
  # set_get("book/kamoku",%w(edit_on_table_all_column))

  ############ しまだ
  # %w(shimada/month shimada/chubu/month).each{ |shimada|
  #   %w( analyze power  reset_reevice_and_ave reculc_all reculc_shapes rm_gif standerd
  #    show_analyze show_gif).each{ |act|
  #     get  "/#{shimada}/#{act}" =>  "#{shimada}##{act}"
  #   }
  #   %w(graph graph_month graph_month_temp graph_month_bugs   
  #      graph_the_day graph_patarn_all_month graph_deform graph_line 
  #      graph_all_month graph_all_by_month  graph_all_month_vaper graph_all_month_temp 
  #      graph_all_month_bugs graph_all_month_offset graph_all_month_bugs_offset
  #       graph_all_month_lines 
  #      graph_simyartion graph_almighty graph_superman graph_superman2

  #      graph_all_days
  #   ).each{ |act|
  #     get  "/#{shimada}/#{act}" =>  "#{shimada}##{act}"
  #   }

  #   %w(today tomorrow).each{ |day|
  #     get "/#{shimada}/#{day}" => "#{shimada}##{day}"
  #   }
  #   set_post(shimada,@EditTable)
  # }
  #   %w(month power chubu/month).each{  |model|
  #     set_resources("shimada",model) 
  #   }
  # controller="shimada/factory"
  # #set_post(controller,@EditTable)
  # set_get(controller,%w(today update_today clear_today update_tomorrow))
  set_get("show_graph",["show_img"])
  set_get("shimada/daylies",
          %w(index_month show_img img_table
             graph graph_weather graph_dayly graph_month graph_temp_hyum_vaper))
  set_get("shimada/factory",%w(img_table data_graph_table day_graph show_img
                               this_month prev_day next_day this_day prev_month next_month))
  
  edit_table("shimada/factory","shimada/instrument","shimada/graph_define")
  namespace :shimada do
    resources :daylies,:instrument,:factory,:graph_define
  end

  ######### 熱管理
  %w(monthly_graph monthly_scatter ).
    each{ |act|
    get  "/power/ube_hospital/month/#{act}" =>  "power/ube_hospital/month##{act}"
  }
  get  "/power/month/show_jpeg" =>  "power/month#show_jpeg"
  resources "power_ube_hospital_month" ,path:  "/power/ube_hospital/month" , controller: "power/ube_hospital/month"
  set_post( "power/ube_hospital/month",@EditTable)

  ######### 休日登録
  set_post(:holydays,%w(years edit)+@EditTable)
  set_get(:holydays,%w(years)+@EditTable)
  resources :holydays

  ########## 病院勤務管理

  set_get("hospital/meetings",@EditTable)
  set_post("hospital/meetings",@EditTable)
  namespace :shospital do
    set_get(:roles,[:show_assign,:set_busho])
    set_get(:meetings, %w( show_assign set_busho_month))
    set_post(:meetings, %w(set_busho_month assign update_assign))
    set_post(:roles,%w(assign update_assign))
    set_get(:monthly,[:show_assign,:hope_regist,:hope_update,:assign,:clear_assign,:set_busho_month,:error_disp])
    set_post(:monthly,%w( set_busho_month hope_update))
    set_post(:avoid_combination,%w(set_busho))
    set_get(:form9,[:calc])
    [:nurces,:needs].each{|model| set_get(model,[:set_busho]);set_post(model,[:set_busho])}
    [:bushos,:kinmucodes,:nurces, :roles, :avoid_combination,:needs].each{ |model| set_post(model,@EditTable)}
    resources :bushos, :nurces, :kinmucodes, :roles, :avoid_combination,:needs,:meetings
    resources :monthly,:holyday, :form9
  end

end

