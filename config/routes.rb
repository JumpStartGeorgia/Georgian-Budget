Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    post '/users', to: 'users#create'

    devise_for :users,
               controllers: {
                 confirmations: 'users/confirmations',
                 omniauth: 'users/omniauth',
                 passwords: 'users/passwords',
                 registrations: 'users/registrations',
                 sessions: 'users/sessions',
                 unlocks: 'users/unlocks'
               },
               path_names: {sign_in: 'login', sign_out: 'logout'},
               constraints: { format: :html }

    match '/admin', :to => 'admin#index', :as => :admin, :via => :get
    namespace :admin do
      resources :users, constraints: { format: :html }
      resources :page_contents, constraints: { format: :html }
    end

    get '/explore/:nameable_type/:nameable_id',
        to: 'root#temp_nameable_show',
        as: 'nameable'

    root 'root#index'
    get '/explore' => 'root#explore'
    get '/about' => 'root#about'
    get '/list' => 'root#list'
    get '/csv/complete_primary_finances' => 'csv#complete_primary_finances'

    get '/:version' => 'api#main',
        as: 'api',
        controller: 'api',
        constraints: { format: :json }

    # handles /en/fake/path/whatever
    get '*path', to: redirect("/#{I18n.default_locale}")
  end

  # handles /
  get '', to: redirect("/#{I18n.default_locale}")

  # handles /not-a-locale/anything
  get '*path', to: redirect("/#{I18n.default_locale}/%{path}")
end
