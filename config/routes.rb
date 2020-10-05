=begin

Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end

CloudBabel::Engine.routes.draw do

    root to: "dashboards#show"

    resource :translation do
        scope module: :translation do
            resources :strings do
                member do
                    scope :resources do
                        put "need-help"
                        put "need-translation"
                    end
                end
            end
            resources :modules do
                resources :strings, only: [:index]
                resources :buckets do
                    resources :strings
                end
            end
        end

        collection do
            get :search
            get :options
            scope :resources do
                get  :stats
                post :clean
                post :deploy
                post :synchronization
                get  :download
            end
        end

    end

    resources :modules

end
