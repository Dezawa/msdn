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
 

  root :to => "top#msdn"
  devise_for :users

  resources :user_options,:users

  
  get    '/users/edit' =>            'users#edit'
  post   '/users'  =>                'users#update' , as: :user_create
  patch  '/users'  =>                'users#update'
  put    '/users'  =>                'users#update'
  delete '/users'  =>                'users#destroy'

  
  %w(user_options users ).
    each{|controller| 
    %w(add_on_table edit_on_table update_on_table csv_out csv_upload edit new).
    each{|action|
      post "#{controller}/#{action}" => "#{controller}##{action}"
    }}
    
  get  '/ubr/main' =>  'ubr/main#index'
  ubr = %w(main waku waku_block souko_plan souko_floor wall pillar)
    ubr.each{ 
    |controller|  
    %w(index add_on_table edit_on_table update_on_table csv_out csv_upload ).
    each{ |action| post "/ubr/#{controller}/#{action}" => "ubr/#{controller}##{action}" 
    }
    %w(index edit ).each{ |action| get "/ubr/#{controller}/#{action}" => "ubr/#{controller}##{action}" 
    }
  }

  %w(occupy_pdf reculc show_pdf).each{ |act| 
    get  "/ubr/main/#{act}" =>  "ubr/main##{act}"
  }

  ubr.each{ |ctrl|
    resources "ubr_#{ctrl}" , controller: "ubr/#{ctrl}"
  }
 end
