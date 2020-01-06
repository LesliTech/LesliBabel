CloudBabel::Engine.routes.draw do

    resources :translation_object_group_section_labels
    resources :translations do
        resources :translation_objects do 
            resources :translation_object_groups do
                resources :translation_object_group_sections do
                    resources :translation_object_group_section_labels
                end
            end
        end
    end

    root to: 'dashboards#default'

end
