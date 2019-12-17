CloudBabel::Engine.routes.draw do
  resources :translation_object_group_labels
  resources :translation_object_groups
    resources :translations do
        resources :translation_objects do 
                  end
    end
    root to: 'dashboards#default'
end
