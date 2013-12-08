Msdn::Application.routes.draw do
  def set_routes(controller,actions)
    actions[0].each{|action|
      get "#{controller}/#{action}" => "#{controller}##{action}"
    }
    actions[1].each{|action|
      post "#{controller}/#{action}" => "#{controller}##{action}"
    }
  end

  devise_for :users
  root :to => "top#msdn"
  get     "top" => "top#msdn"
  get     "change_password" => "users#change_password"
  post    "password_update" => "users#password_update"

  resources :user_options,:users
  put "users/new" => "users#create"
  
  actions = [%w(add_on_table edit_on_table csv_out),%w(add_on_table edit_on_table update_on_table)]
  %w(user_options users book/main book/kamoku).
    each{|controller| 
       set_routes(controller,actions)
    }
    
  controller = "book/keeping"
  actions    = [%w(taishaku motocho error csv_motocho csv_taishaku help),%w(owner_change_win)]
  set_routes(controller,actions)

  controller = "book/main"
  actions    = [%w( book_make  csv_out_print csv_upload ),
                %w(set_const count kaisizandaka_count renumber sort_by_tytle make_new_year
                   csv_out)
               ]
  set_routes(controller,actions)

  controller = "book/kamoku"
  actions = [[],%w(edit_on_table_all_column csv_out)]
  set_routes(controller,actions)

  namespace :book do
    resources :keeping, :kamoku, :main, :permission
    #post "book/keeping/owner_change_win" => "keeping#owner_change_win"
  end
  
  controller = "lips"
  actions = [%w(free member csv_download  ube_hospital),%w(change_form csv_upload calc)]
  set_routes(controller,actions)

  controller = "ubr/main"
  actions    = [%w(index occupy_pdf reculc),%w( csv_upload)]
  set_routes(controller,actions)
  get "ubr/main" => "ubr/main#index"

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
