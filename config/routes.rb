CloudBabel::Engine.routes.draw do

    root to: 'dashboards#default'
    resources :translations
    resource :dashboard

end
