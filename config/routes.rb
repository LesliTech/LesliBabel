CloudBabel::Engine.routes.draw do

    resource :translation do
        scope module: :translation do
            resources :strings
            resources :modules do
                resources :objects do
                    resources :strings
                end
            end
        end
    end

    root to: 'dashboards#default'

end
