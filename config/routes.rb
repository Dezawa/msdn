Msdn::Application.routes.draw do
  def set_routes(controller,actions)
    actions[0].each{|action|
      get "#{controller}/#{action}" => "#{controller}##{action}"
    }
    actions[1].each{|action|
      post "#{controller}/#{action}" => "#{controller}##{action}"
    }
  end

  ### Special routs #####
  devise_for :users
  root :to => "top#msdn"
  get     "top" => "top#msdn"
  get     "change_password" => "users#change_password"
  post    "password_update" => "users#password_update"
  put "users/new" => "users#create"

  get  "ubr/main" => "ubr/main#index"
  get  "ubeboard/top" => "ubeboard/top#top"
  get  "ubeboard/lips/member" => "lips#member"


  #### EditTable #########

  actions = [%w(add_on_table edit_on_table csv_out),%w(add_on_table edit_on_table update_on_table)]
  %w(user_options users book/main book/kamoku   ).
    each{|controller| 
       set_routes(controller,actions)
    }
   %w(plan maintain holyday product operation change_times meigara meigara_shortname
      constant named_changes 
    ).
    each{|controller| 
       set_routes("ubeboard/"+controller,actions)
    }

    
  ##### Controller ######
  ## [ controller,[get_actions,post_actions] ]
  [ ["book/keeping",
     [%w(taishaku motocho error csv_motocho csv_taishaku help),
      %w(owner_change_win)]],
    ["book/main",
     [%w( book_make  csv_out_print csv_upload ),
      %w(set_const count kaisizandaka_count renumber sort_by_tytle make_new_year csv_out)
     ]],
    ["book/kamoku", [[],%w(edit_on_table_all_column csv_out)]],
    ["lips"       , 
     [%w(free member csv_download  hospital calc),
      %w(change_form csv_upload calc)]
    ],
    ["ubr/main"   , 
     [%w(index occupy_pdf reculc show_pdf),
      %w( csv_upload)]
    ],
    ["ubeboard/lips",
     [%w(member),[]]
    ]
  ].
    each{|controller,actions| set_routes(controller,actions) }
    

  #### resources namespaces #####
  resources :user_options,:users

  namespace :book do
    resources :keeping, :kamoku, :main, :permission
    #post "book/keeping/owner_change_win" => "keeping#owner_change_win"
  end
  
  ubeboard_resources = [:skd,:maintain,:holyday,:product,:operation,
                        :change_times,:meigara,:meigara_shortname,:constant,
                        :named_changes,:plan]
  namespace :ubeboard do
    resources *ubeboard_resources 
    ubeboard_resources.each{|ctrl| post "#{ctrl}/csv_out" => "#{ctrl}#csv_out"}
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
end
