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

    resources :relevants, only: [:index]

    # working with strings
    resources :strings, only: [:index, :create, :update] do 
        collection do 
            get :stats
            get :locales
            get :relevant
        end 
    end 

    # working with translations
    resources :translations, only: [:index] do 
        collection do 
            get :options
            post :renovate
            post :deploy 
            post :sync
        end 
    end 

    # working with modules
    resources :modules, only: [:index, :show, :new, :create, :edit] do 
        resources :buckets, only: [:index]
    end

end
