CloudBabel::Engine.routes.draw do
    resources :translations
    resources :translation_objects
    resources :translation_object_strings
    root to: 'dashboards#default'
end
