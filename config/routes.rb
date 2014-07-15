# -*- coding: utf-8 -*-
ActionController::Routing::Routes.draw do |map|
  # 全体
  map.connect '/:controller/:action',:action => /[^0-9]+/
  map.resources :weather
  # シマダヤ
  map.connect '/shimada/:controller/:action'  ,:path_prefix => 'shimada'#,:action => /[^0-9]+/
  map.connect '/shimada/:controller'  ,:path_prefix => 'shimada'#,:action => /[^0-9]+/
  map.resources :shimada_month       ,:controller => 'shimada/month'
  map.resources :shimada_factory       ,:controller => 'shimada/factory'

  # UBR
#  map.connect '/ubr/倉庫状況.pdf'  ,:url => '/public/ubr/倉庫状況.pdf'
  map.connect '/ubr/:controller/:action'  ,:path_prefix => 'ubr'#,:action => /[^0-9]+/
  map.connect '/ubr/:controller'  ,:path_prefix => 'ubr'#,:action => /[^0-9]+/
  map.resources :ubr_waku       ,:controller => 'ubr/waku'
  map.resources :ubr_pillar     ,:controller => 'ubr/pillar'
  map.resources :ubr_wall       ,:controller => 'ubr/wall'
  map.resources :ubr_waku_block       ,:controller => 'ubr/waku_block'
  map.resources :ubr_souko_plan       ,:controller => 'ubr/souko_plan'
  map.resources :ubr_souko_floor       ,:controller => 'ubr/souko_floor'
  map.resources :ubr_souko_floor_souko_plan  ,:controller => 'ubr/souko_floor'
  # 病院
  map.connect '/hospital/:controller/:action'  ,:path_prefix => 'hospital'
  map.connect '/hospital/:controller'  ,:path_prefix => 'hospital'

  map.resources :holyday
  map.resources :hospital_nurces ,:controller => "hospital/nurces"
  map.resources :hospital_role ,:controller => "hospital/role"
  map.resources :hospital_need ,:controller => "hospital/need"
  map.resources :hospital_meeting,:controller => "hospital/meeting"
  map.resources :hospital_kinmucode,:controller => "hospital/kinmucode"
  map.resources :hospital_shokui,:hospital_shokushu,:hospital_kinmukubun
  map.resources :hospital_limit ,:hospital_busho  , :hospital_monthly
  map.resources :hospital_avoid_combination,:controller => "hospital/avoid_combination"
  map.resources :labels

  # 簿記
  map.connect '/book/:controller/:action'  ,:path_prefix => 'book'
  map.connect '/book/:controller'  ,:path_prefix => 'book'
  map.connect '/book/keeping/:action' ,:controller => 'book/keeping'
  map.resources :book_main       ,:controller => 'book/main'
  map.resources :book_permission ,:controller => 'book/permission'
  map.resources :book_kamoku     ,:controller => 'book/kamoku'


  # ん～～～と
  map.top    '/'      ,:controller => 'top',        :action => 'msdn'

  # ユーザ管理
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.change_password '/change_password', :controller => 'users', :action => 'change_password'
  map.resources :users
  map.resources :user_options
  map.resource :session

  # LiPS
  map.lips   '/LinierPlanGeneral', :controller => 'top_pages', :action => 'linier_plan_general'

  #map.connect   '/ube_skd/lips_load',:controller => 'ube_skd',:action=>:lips_load
  map.select    '/ube_skd/select' ,:controller => 'ube_skd', :action => 'select'
  map.connect   '/ube_skd/input_result',:controller => 'ube_skd',:action=>:input_result
  map.resources :ube_skd,:ube_plan
  map.resources :ube_maintain
  map.resources :ube_meigara
  map.resources :ube_meigara_shortname
  map.resources :ube_constant
  map.connect   '/ube_holyday/edit_on_table'   ,:controller => 'ube_holyday',  :action => "edit_on_table"
  map.connect   '/ube_holyday/add_on_table'   ,:controller => 'ube_holyday',  :action => "add_on_table"
  map.connect   '/ube_holyday/update_on_table'   ,:controller => 'ube_holyday',  :action => "update_on_table"
  map.resources :ube_holyday
  #map.resources :ubeboard
  map.resources :ube_product
  map.resources :ube_operation
  #map.resources :ube_operations
  map.resources :Top
  map.connect   '/ubeboard/:action',:controller => 'ubeboard'
  map.connect   '/ubeboard/lips_load',:controller => 'ubeboard',:action=>:lips_load
  map.connect   '/ube_skd/:action',:controller => 'ube_skd'
  map.connect   '/ube_skd/makeplan',:controller => 'ube_skd',:action=>:makeplan
  map.connect   '/ube_product/:action',:controller => 'ube_product'
  map.connect   '/ube_plan/:action',:controller => 'ube_plan'
  map.connect   '/user_options/:action',:controller => 'user_options'
  map.connect   '/:controller/csv_upload',:action => "csv_upload"
  map.resources :ube_named_changes
#
#

#
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
