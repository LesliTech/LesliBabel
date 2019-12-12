CloudBabel::Engine.routes.draw do
    resources :translations do
        resources :translation_objects do 
            resources :translation_object_strings
        end
    end
    root to: 'dashboards#default'
end
