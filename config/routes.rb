=begin

Lesli

Copyright (c) 2025, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by LesliTech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

LesliBabel::Engine.routes.draw do  

    Lesli::Routing.mount_dashboard_for(LesliBabel)

    resources :labels, only: [:index, :new, :create, :show, :update]

    # working with modules
    resources :modules, only: [:index, :show] do 
        resources :buckets, only: [:index]
    end

    # working with translations
    resources :translations, only: [] do 
        collection do 
            get :options
            post :renovate
            get :deploy 
            post :sync
        end 
    end 

    # relevant strings
    resources :relevants, only: [:index]

    # working with strings
    resources :strings, only: [] do 
        collection do 
            get :stats
            get :locales
            get :relevant
        end 
    end 

    get "up" => "/rails/health#show"
end
