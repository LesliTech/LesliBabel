=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

Lesli - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  <hello@lesli.tech>
@website  <https://lesli.tech>
@license  Propietary - all rights reserved.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end

CloudBabel::Engine.routes.draw do

    resource :translation do
        scope module: :translation do
            resources :strings do
                member do
                    put "need_help"
                    put "need_translation"
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
            post "clean"
            post "deploy"
            get  "stats"
            get  "search"
            post "synchronization"
        end
    end

    root to: "dashboards#stats"

end
