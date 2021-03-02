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

    resources :modules, only: [:index, :show, :new, :create, :edit] do
        resources :strings, only: [:index]
        resources :buckets, only: [:index, :create] do 
            resources :strings, only: [:index]
        end
    end

    resources :strings, only: [:index, :create, :update, :destroy] do 
        collection do
            scope :resources do
                get  :relevant
                get  :search
                get  :stats
                get  :available_locales
            end
        end
        scope module: :string do
            resources :discussions, only: []
            resources :activities,  only: []
        end
    end

    resources :translations, only: [:index] do 
        collection do
            get :options
            scope :resources do
                post :deploy
                post :renovate
                post :synchronization
                get  :download
            end
        end
    end

end
