SMO::Application.routes.draw do  
  get "upgrade/index"

  devise_for :superadmins, :controllers => {:sessions => "superadmin/sessions"}
  
  unauthenticated :superadmin do
    devise_scope :superadmin do
      get "superadmin_login",:to => "superadmin/sessions#new" ,:as => "superadmin_login"
      get "superadmin_sign_out", :to => "superadmin/sessions#destroy",:as => "superadmin_logout"
    end
  end
  
  namespace :superadmin do
    resources :companies do
      member do
        put :inactivate_company
        put :activate_company
      end
    end
    resources :dashboards do
      collection do
        get :users_list
      end
    end
  end
  
  authenticated :superadmin do
    root :to => "superadmin/dashboards#index"
  end
  
  get "settings/index"

  resources :subscriptions do
    collection do
      get :billing
    end
  end

  resources :trial_expires
  resources :quickbooks
  resources :businesses
  resources :jobstatuses
  resources :reports do
    collection do
      get :push_report_to_quickbook
    end

    member do
      post :send_mail
      get :job_report
    end    
  end
  resources :customs do
    collection do
      get :add_drop_values
      put :update_position
      get :get_dropdown_values
      get :edit_dropdown
      get :new_tab
      post :create_tab
      get :edit_table
      get :edit_table_heading
      post :create_table_fields
      post :email_customer
    end

    member do
      get :edit_legend_field
      put :update_legend_field
      put :update_tab
      match :update_dropdown_values
      put :update_dropdown
      put :update_status
      put :update_table
      put :update_heading
      delete :delete_table
      match :update_customer_selection
      get :print_custominfo
      post :email_custominfo
    end
  end

  resources :customers do
    member do
      put :inactive_cust
      put :active_cust
    end
  end
  resources :jobsites do
    member do
      get :ajax_show
      get :get_id
      get :show_jobsite
      get :get_jobsite
    end
  end

  resources :settings do
    collection do 
      get   :accounting
      match :authenticate
      match :oauth_callback
      match :dis_quickbooks
      match :bluedot
      get   :sync_customer_data
      get   :sync_items
      get   :sync_employees
      get   :sync_vendors
      get   :sync_salse_person
    end
  end

  resources :roles
  
  resources :contacts do
    member do
      get :ajax_show
    end
  end

  resources :jobs do
    member do
      get :job_pdf
      put :close_job
      put :invoice_job
      get :invoice_and_pay
      get :print_invoice
      get :convert_to_invoice
      post :email_invoice
      post :process_invoice
      get :email_jobdetails
      post :send_invoice
      get :print_invoice_pay
      post :send_invoice_qbo
      get :close_job_invoice
      get :change_customer
      put :change_customer_jobsite
    end
    
    collection do
      get :my_jobs
      get :recurring_list
    end
  end

  
  resources :recurrings
  resources :items do
    collection do
      get :autocomplete_items
      get :create_inventory
    end
  end
 
  resources :documents 

  resources :inventories

  resources :jobtimes do
    collection do
      post :jobtime_shedule
    end
  end
  
  resources :notes
  devise_for :users

  resources :users do
    member do
      put :deactivate_user
    end
  end

  match 'users/create' => "users#create",:as => :create_user

  get "dashboards/index"

  devise_for :companies, :controllers => {:sessions => 'sessions', :omniauth_callbacks => "omniauth_callbacks"}

  authenticated :company do
    root :to => "dashboards#index"
  end

  authenticated :user do
    root :to => "dashboards#index"
  end
  
  unauthenticated :user do
    devise_scope :user do
      post "api/users/sign_in", :to => "api/users_sessions#create"
      delete "api/users/sign_out", :to => "api/users_sessions#destroy"
      post "api/users/sign_up", :to => "api/registrations#users_create"
    end
  end
  
  unauthenticated :company do
    devise_scope :company do
      get "/" => "devise/sessions#new"
      post "api/sign_in", :to => "api/sessions#create"
      delete "api/sign_out", :to => "api/sessions#destroy"
      post "api/sign_up", :to => "api/registrations#create"
      get "sign_out", :to => "devise/sessions#destroy", :as => "logout"
     end
  end
  

  # routes for api
  namespace :api do
    resources :customers
    resources :jobsites
    resources :notes
    resources :documents

    resources :items do
      collection do
        get :autocomplete_items
        get :create_inventory
      end
    end
    resources :inventories
    resources :jobtimes do
      collection do
        post :jobtime_shedule
      end
    end


    resources :dashboards
    resources :contacts 
    resources :jobs do
      member do
        put :close_job
      end
    end
    resources :customs do
      collection do
        post  :create_tab
      end
      member do
        put   :update_tab
        put   :update_dropdown_values
        put   :update_dropdown
        put   :update_status
      end
    end
  end
  
  # end of routes for api

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
