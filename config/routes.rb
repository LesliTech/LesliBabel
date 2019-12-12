CloudBabel::Engine.routes.draw do
    resources :translations do
        resources :translation_objects
    end
    resources :translation_object_strings
    root to: 'dashboards#default'
end
